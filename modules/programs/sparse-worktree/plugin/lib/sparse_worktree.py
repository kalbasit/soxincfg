#!/usr/bin/env python3
"""Create and maintain sparse git worktrees of large repositories.

Repositories opt in through the config file (see load_config). Their new worktrees get a cone
sparse checkout with a sparse index, and missing-path errors widen the cone on demand.
"""

from __future__ import annotations

import argparse
import fnmatch
import json
import os
import re
import shutil
import subprocess
import sys
from dataclasses import dataclass, field
from pathlib import Path

DEFAULT_MAX_AUTO_ADD_FILES = 25000
MAX_SYMLINK_ROUNDS = 5


def load_config() -> dict:
    path = os.environ.get("SPARSE_WORKTREE_CONFIG") or os.path.join(
        os.environ.get("XDG_CONFIG_HOME") or os.path.expanduser("~/.config"),
        "sparse-worktree",
        "config.json",
    )
    try:
        with open(path) as f:
            return json.load(f)
    except FileNotFoundError:
        return {"repos": {}}


def real_git() -> str:
    shim_dir = os.environ.get("SPARSE_WORKTREE_SHIM_DIR")
    for d in os.environ.get("PATH", "").split(os.pathsep):
        if not d or (shim_dir and os.path.realpath(d) == os.path.realpath(shim_dir)):
            continue
        candidate = os.path.join(d, "git")
        if os.path.isfile(candidate) and os.access(candidate, os.X_OK):
            return candidate
    sys.exit("sparse-worktree: no git binary found on PATH")


def git(*args: str, cwd: str | None = None, check: bool = True, stdin: str | None = None,
        env: dict | None = None) -> subprocess.CompletedProcess:
    return subprocess.run(
        [real_git(), *args],
        cwd=cwd,
        input=stdin,
        capture_output=True,
        text=True,
        check=check,
        env=env,
    )


def git_out(*args: str, cwd: str | None = None) -> str | None:
    r = git(*args, cwd=cwd, check=False)
    return r.stdout.strip() if r.returncode == 0 else None


def parse_remote(url: str) -> str | None:
    url = url.strip()
    m = re.match(r"^[a-z+]+://(?:[^@/]+@)?([^/:]+)(?::\d+)?/(.+?)(?:\.git)?/?$", url)
    if not m:
        m = re.match(r"^(?:[^@/]+@)?([^/:]+):(.+?)(?:\.git)?/?$", url)
    return f"{m.group(1)}/{m.group(2)}" if m else None


def toplevel(path: str) -> str | None:
    p = Path(path)
    while not p.exists() and p != p.parent:
        p = p.parent
    if p.is_file():
        p = p.parent
    return git_out("rev-parse", "--show-toplevel", cwd=str(p))


def repo_settings(repo_dir: str) -> dict | None:
    url = git_out("config", "--get", "remote.origin.url", cwd=repo_dir)
    key = parse_remote(url) if url else None
    if not key:
        return None
    settings = load_config().get("repos", {}).get(key)
    if settings is None:
        return None
    return {"key": key, "dirs": list(settings.get("dirs", [])),
            "maxAutoAddFiles": int(settings.get("maxAutoAddFiles", DEFAULT_MAX_AUTO_ADD_FILES))}


def is_sparse(root: str) -> bool:
    return git_out("config", "--get", "core.sparseCheckout", cwd=root) == "true"


def cone_dirs(root: str) -> list[str]:
    out = git_out("sparse-checkout", "list", cwd=root)
    return [l for l in (out or "").splitlines() if l]


def in_cone(path: str, cones: list[str]) -> bool:
    if "/" not in path:
        return True
    return any(path == c or path.startswith(c + "/") for c in cones)


def object_types(root: str, paths: list[str]) -> dict[str, str]:
    if not paths:
        return {}
    r = git("cat-file", "--batch-check=%(objecttype)", cwd=root, check=False,
            stdin="".join(f"HEAD:{p}\n" for p in paths))
    types = {}
    for p, line in zip(paths, r.stdout.splitlines()):
        types[p] = line.split()[0] if line and "missing" not in line else ""
    return types


def file_count(root: str, d: str) -> int:
    r = git("ls-tree", "-r", "--name-only", "HEAD", "--", d, cwd=root, check=False)
    return r.stdout.count("\n")


def normalize(root: str, path: str, base: str | None = None) -> str | None:
    p = Path(path)
    if not p.is_absolute():
        p = Path(base or root) / p
    p = Path(os.path.normpath(p))
    try:
        rel = p.relative_to(root)
    except ValueError:
        return None
    rel_s = rel.as_posix()
    if rel_s in ("", ".") or rel_s.startswith(".git/") or rel_s == ".git":
        return None
    return rel_s


@dataclass
class AddResult:
    added: dict[str, int] = field(default_factory=dict)
    skipped: dict[str, int] = field(default_factory=dict)


def resolve_dirs(root: str, rel_paths: list[str], cones: list[str]) -> list[str]:
    candidates: list[str] = []
    for p in dict.fromkeys(rel_paths):
        parts = p.split("/")
        prefixes = ["/".join(parts[:i]) for i in range(len(parts), 0, -1)]
        types = object_types(root, prefixes)
        for prefix in prefixes:
            t = types.get(prefix)
            if t == "tree":
                candidates.append(prefix)
                break
            if t in ("blob", "commit"):
                parent = prefix.rpartition("/")[0]
                if parent:
                    candidates.append(parent)
                break
    result = []
    for d in dict.fromkeys(candidates):
        if not in_cone(d + "/x", cones) and not any(d.startswith(o + "/") for o in result):
            result = [o for o in result if not o.startswith(d + "/")]
            result.append(d)
    return result


def dangling_symlink_targets(root: str, dirs: list[str]) -> list[str]:
    if not dirs:
        return []
    r = git("ls-tree", "-r", "HEAD", "--", *dirs, cwd=root, check=False)
    targets = []
    for line in r.stdout.splitlines():
        meta, _, path = line.partition("\t")
        if not meta.startswith("120000"):
            continue
        link = Path(root) / path
        if link.exists() or not link.is_symlink():
            continue
        rel = normalize(root, os.readlink(link), base=str(link.parent))
        if rel:
            targets.append(rel)
    return targets


def add_paths(root: str, rel_paths: list[str], limit: int | None, force: bool = False) -> AddResult:
    result = AddResult()
    pending = rel_paths
    for _ in range(MAX_SYMLINK_ROUNDS):
        cones = cone_dirs(root)
        dirs = resolve_dirs(root, pending, cones)
        to_add = []
        for d in dirs:
            if d in result.skipped:
                continue
            n = file_count(root, d)
            if not force and limit is not None and n > limit:
                result.skipped[d] = n
            else:
                to_add.append(d)
                result.added[d] = n
        if not to_add:
            break
        git("-c", "checkout.workers=0", "sparse-checkout", "add", *to_add, cwd=root)
        pending = dangling_symlink_targets(root, to_add)
        if not pending:
            break
    return result


def close_symlinks(root: str, limit: int | None) -> AddResult:
    return add_paths(root, dangling_symlink_targets(root, cone_dirs(root)), limit)


# --- error parsing ---------------------------------------------------------------------------

MISSING_HINT = re.compile(
    r"No such file or directory|not found|does not exist|cannot access|can't open|could not open|"
    r"ENOENT|FileNotFoundError|No such package|no such package|cannot load|Nonexistent path|"
    r"Is there a file at|corresponding package|outside of your sparse-checkout|"
    r"ModuleNotFoundError|Cannot find module|unable to find|Unable to find|is not a package",
)

BAZEL_LABEL_PATTERNS = [
    re.compile(r"Label '(?:@@?)?//([^:']+):[^']*' is invalid because '[^']+' is not a package"),
    re.compile(r"no such package '(?:@@?//|//)?([^'@:/][^':]*)'"),
    re.compile(r"cannot load '(?:@@?)?//([^:']*):[^']+'"),
    re.compile(r"Every \.bzl file must have a corresponding package, but '(?:@@?)?//([^:']+):"),
    re.compile(r"Unable to find package for (?:@@?)?//([^:\s]+):"),
]
PATH_PATTERNS = [
    re.compile(r"Is there a file at (\S+?)\?"),
    re.compile(r"Nonexistent path in import declaration in config file '[^']*': 'import %workspace%/([^']+)'"),
]
SPARSE_PATHSPEC_HEADER = "outside of your sparse-checkout definition"
TOKEN = re.compile(r"""[`'"(\[]?((?:/|\.{1,2}/|[\w.@+-]+/)[\w./@+-]*[\w@+-])""")


def extract_candidates(text: str) -> list[tuple[str, str]]:
    found: list[tuple[str, str]] = []
    for pat in BAZEL_LABEL_PATTERNS:
        for m in pat.finditer(text):
            if m.group(1):
                found.append((m.group(1), "bazel package"))
    for pat in PATH_PATTERNS:
        for m in pat.finditer(text):
            found.append((m.group(1), "missing path"))
    lines = text.splitlines()
    for i, line in enumerate(lines):
        if SPARSE_PATHSPEC_HEADER in line:
            for nxt in lines[i + 1:]:
                if not nxt.strip() or nxt.lower().startswith("hint:"):
                    break
                found.append((nxt.strip(), "git pathspec outside sparse checkout"))
    for line in lines:
        if len(line) > 2000 or not MISSING_HINT.search(line):
            continue
        for m in TOKEN.finditer(line):
            tok = re.sub(r"(:\d+)+$", "", m.group(1)).rstrip(".")
            if 2 < len(tok) < 400 and "//" not in tok and not tok.startswith("@"):
                found.append((tok, "missing path"))
    return list(dict.fromkeys(found))


def fix_from_text(roots: list[str], text: str, base: str | None, limit_override: int | None = None) -> dict:
    report: dict[str, dict] = {}
    if not MISSING_HINT.search(text):
        return report
    candidates = extract_candidates(text)
    if not candidates:
        return report
    for root in roots:
        settings = repo_settings(root)
        if not settings or not is_sparse(root):
            continue
        cones = cone_dirs(root)
        rels = []
        reasons = {}
        for tok, why in candidates:
            for b in (base, root):
                rel = normalize(root, tok, base=b)
                if rel and not in_cone(rel, cones) and not (Path(root) / rel).exists():
                    rels.append(rel)
                    reasons.setdefault(rel, why)
                    break
        if not rels:
            continue
        limit = limit_override if limit_override is not None else settings["maxAutoAddFiles"]
        res = add_paths(root, rels, limit)
        if res.added or res.skipped:
            report[root] = {"added": res.added, "skipped": res.skipped,
                            "reasons": sorted(set(reasons.values()))}
    return report


def describe(report: dict, limit_hint: bool = True) -> str:
    parts = []
    for root, r in report.items():
        if r["added"]:
            dirs = ", ".join(f"`{d}` ({n} files)" for d, n in r["added"].items())
            parts.append(f"sparse-worktree: added {dirs} to the sparse checkout of {root} "
                         f"({'; '.join(r['reasons'])} outside the cone). Re-run the command.")
        if r["skipped"]:
            dirs = ", ".join(f"`{d}` ({n} files)" for d, n in r["skipped"].items())
            parts.append(f"sparse-worktree: {dirs} in {root} is outside the sparse checkout and too big to "
                         f"add automatically. If it is needed, run `sparse-worktree add --force <dir>` "
                         f"(or a narrower subdirectory), or read it without checkout via "
                         f"`git show HEAD:<path>` / `git grep <pattern> HEAD -- <dir>`.")
    return "\n".join(parts)


# --- worktree creation -----------------------------------------------------------------------

ADD_VALUE_OPTS = {"-b", "-B", "--reason", "--orphan"}


def worktree_add_path(add_args: list[str]) -> str | None:
    i = 0
    positional = []
    while i < len(add_args):
        a = add_args[i]
        if a == "--":
            positional.extend(add_args[i + 1:])
            break
        if a in ADD_VALUE_OPTS:
            i += 2
            continue
        if a.startswith("-"):
            i += 1
            continue
        positional.append(a)
        i += 1
    return positional[0] if positional else None


def create_sparse(repo: str, add_args: list[str], settings: dict, quiet: bool = False) -> str:
    rel_path = worktree_add_path(add_args)
    if not rel_path:
        sys.exit("sparse-worktree: cannot find the worktree path in the git worktree add arguments")
    path = os.path.normpath(os.path.join(repo, rel_path))
    r = subprocess.run([real_git(), "-C", repo, "worktree", "add", "--no-checkout", *add_args],
                       stdout=sys.stderr if quiet else None)
    if r.returncode != 0:
        sys.exit(r.returncode)
    dirs = settings["dirs"]
    subprocess.run([real_git(), "-C", path, "-c", "checkout.workers=0", "sparse-checkout", "set",
                    "--cone", "--sparse-index", *dirs], check=True, stdout=sys.stderr if quiet else None)
    subprocess.run([real_git(), "-C", path, "-c", "checkout.workers=0", "checkout", "-q"],
                   check=True, stdout=sys.stderr if quiet else None)
    res = close_symlinks(path, settings["maxAutoAddFiles"])
    msg = f"sparse-worktree: {path} is a sparse checkout of {settings['key']} ({' '.join(cone_dirs(path))})"
    if res.added:
        msg += f"; followed symlinks into {' '.join(res.added)}"
    print(msg, file=sys.stderr)
    return path


def split_global_opts(argv: list[str]) -> tuple[list[str], list[str], str]:
    cwd = os.getcwd()
    i = 0
    globals_ = []
    while i < len(argv):
        a = argv[i]
        if a in ("-C", "-c", "--git-dir", "--work-tree", "--namespace") and i + 1 < len(argv):
            if a == "-C":
                cwd = os.path.join(cwd, argv[i + 1])
            globals_ += argv[i:i + 2]
            i += 2
        elif a.startswith("-"):
            globals_.append(a)
            i += 1
        else:
            break
    return globals_, argv[i:], cwd


def cmd_git(argv: list[str]) -> None:
    globals_, rest, cwd = split_global_opts(argv)
    if rest[:2] == ["worktree", "add"] and "--no-checkout" not in rest and \
            not any(g.startswith(("--git-dir", "--work-tree")) for g in globals_):
        top = git_out("rev-parse", "--show-toplevel", cwd=cwd) if os.path.isdir(cwd) else None
        settings = repo_settings(top) if top else None
        if settings:
            create_sparse(cwd, rest[2:], settings)
            return
    g = real_git()
    os.execv(g, [g, *argv])


# --- Claude Code worktree hooks --------------------------------------------------------------

def default_base(repo: str) -> str:
    try:
        with open(os.path.expanduser("~/.claude/settings.json")) as f:
            if (json.load(f).get("worktree") or {}).get("baseRef") == "head":
                return "HEAD"
    except (OSError, ValueError):
        pass
    head = git_out("symbolic-ref", "--short", "refs/remotes/origin/HEAD", cwd=repo)
    if not head:
        return "HEAD"
    branch = head.split("/", 1)[1]
    try:
        subprocess.run([real_git(), "-C", repo, "fetch", "--quiet", "origin", branch],
                       timeout=5, capture_output=True)
    except subprocess.TimeoutExpired:
        pass
    return head if git_out("rev-parse", "--verify", "--quiet", head, cwd=repo) else "HEAD"


def copy_worktreeinclude(repo: str, path: str) -> None:
    include = Path(repo) / ".worktreeinclude"
    if not include.is_file():
        return
    patterns = [l.strip() for l in include.read_text().splitlines() if l.strip() and not l.startswith("#")]
    ignored = git_out("ls-files", "--others", "--ignored", "--exclude-standard", cwd=repo) or ""
    for f in ignored.splitlines():
        if any(fnmatch.fnmatch(f, p) or fnmatch.fnmatch(f, p.rstrip("/") + "/*") for p in patterns):
            dst = Path(path) / f
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(Path(repo) / f, dst)


def transcript_cwds(transcript_path: str | None, limit: int = 200) -> list[str]:
    if not transcript_path or not os.path.isfile(transcript_path):
        return []
    with open(transcript_path, "rb") as f:
        f.seek(max(0, os.path.getsize(transcript_path) - 4_000_000))
        lines = f.read().decode(errors="replace").splitlines()
    cwds: list[str] = []
    for line in reversed(lines):
        try:
            c = json.loads(line).get("cwd")
        except (ValueError, AttributeError):
            continue
        if c and c not in cwds:
            cwds.append(c)
            if len(cwds) >= limit:
                break
    return cwds


def session_checkout(data: dict, cwd: str) -> str | None:
    """The checkout the session works in. Claude passes the main repo root as `cwd` even when the
    session started in a linked worktree (e.g. an swm story), so recover that worktree."""
    top = git_out("rev-parse", "--show-toplevel", cwd=cwd)
    common = git_out("rev-parse", "--path-format=absolute", "--git-common-dir", cwd=cwd)
    if not top or not common:
        return top
    for c in [os.environ.get("CLAUDE_PROJECT_DIR"), *transcript_cwds(data.get("transcript_path"))]:
        if not c or not os.path.isdir(c) or f"{os.sep}.claude{os.sep}worktrees{os.sep}" in c + os.sep:
            continue
        if git_out("rev-parse", "--path-format=absolute", "--git-common-dir", cwd=c) != common:
            continue
        candidate = git_out("rev-parse", "--show-toplevel", cwd=c)
        if candidate and candidate != str(Path(common).parent):
            return candidate
    return top


def hook_worktree_create(data: dict) -> None:
    name = data["name"]
    cwd = data.get("cwd") or os.getcwd()
    repo = session_checkout(data, cwd)
    if not repo:
        sys.exit(f"sparse-worktree: {cwd} is not inside a git worktree")
    path = os.path.join(repo, ".claude", "worktrees", name)
    branch = f"worktree-{name}"
    if git_out("rev-parse", "--verify", "--quiet", f"refs/heads/{branch}", cwd=repo):
        add_args = [path, branch]
    else:
        add_args = ["-b", branch, path, default_base(repo)]
    settings = repo_settings(repo)
    if settings:
        create_sparse(repo, add_args, settings, quiet=True)
    else:
        r = subprocess.run([real_git(), "-C", repo, "worktree", "add", *add_args], stdout=sys.stderr)
        if r.returncode != 0:
            sys.exit(r.returncode)
    copy_worktreeinclude(repo, path)
    print(path)


def hook_worktree_remove(data: dict) -> None:
    path = data["worktree_path"]
    common = git_out("rev-parse", "--path-format=absolute", "--git-common-dir", cwd=path)
    if not common:
        sys.exit(f"sparse-worktree: {path} is not a git worktree")
    repo = str(Path(common).parent)
    branch = git_out("symbolic-ref", "--short", "HEAD", cwd=path)
    r = git("worktree", "remove", "--force", path, cwd=repo, check=False)
    if r.returncode != 0 and os.path.exists(path):
        sys.exit(r.stderr.strip() or "git worktree remove failed")
    if not branch or not branch.startswith("worktree-"):
        return
    head = git_out("symbolic-ref", "--short", "refs/remotes/origin/HEAD", cwd=repo) or "HEAD"
    if git("merge-base", "--is-ancestor", branch, head, cwd=repo, check=False).returncode == 0:
        git("branch", "-D", branch, cwd=repo, check=False)


# --- Claude Code tool hooks ------------------------------------------------------------------

CD_TARGET = re.compile(r"(?:^|&&|;|\|\||\()\s*(?:cd|pushd)\s+(\"[^\"]+\"|'[^']+'|[^\s;&|)]+)")
C_TARGET = re.compile(r"\bgit\s+(?:-c\s+\S+\s+)*-C\s+(\"[^\"]+\"|'[^']+'|\S+)")
ABS_PATH = re.compile(r"(/[\w.@+-]+(?:/[\w.@+-]+)+)")
GIT_WORKTREE_ADD = re.compile(
    r"^(\s*(?:cd\s+(?:\"[^\"]+\"|'[^']+'|[^\s;&|]+)\s*&&\s*)?)git(\s+(?:-C\s+\S+\s+)?worktree\s+add\s[^;&|`$()]*)$")
FILE_TOOLS = {"Read": "file_path", "Edit": "file_path", "MultiEdit": "file_path", "Write": "file_path",
              "NotebookEdit": "notebook_path", "Glob": "path", "Grep": "path"}


def unquote(s: str) -> str:
    return s[1:-1] if len(s) > 1 and s[0] == s[-1] and s[0] in "'\"" else s


def command_dirs(cwd: str, command: str) -> list[str]:
    dirs = [cwd]
    for pat in (CD_TARGET, C_TARGET):
        for m in pat.finditer(command):
            dirs.append(os.path.join(cwd, os.path.expanduser(unquote(m.group(1)))))
    return dirs


def sparse_roots(paths: list[str]) -> list[str]:
    roots = []
    seen = set()
    for p in paths:
        if p in seen:
            continue
        seen.add(p)
        top = toplevel(p)
        if top and top not in roots and is_sparse(top):
            roots.append(top)
    return roots


def emit(event: str, context: str) -> None:
    if context:
        print(json.dumps({"hookSpecificOutput": {"hookEventName": event, "additionalContext": context}}))


def hook_session_start(data: dict) -> None:
    cwd = data.get("cwd") or os.getcwd()
    top = toplevel(cwd)
    if not top or not is_sparse(top) or not repo_settings(top):
        return
    emit("SessionStart", (
        f"{top} is a sparse git worktree (cone: {' '.join(cone_dirs(top))}; top-level files are always present). "
        "Paths outside the cone are in git but not on disk, so Glob/Grep/find/rg only see the cone. "
        "To search or read the whole repo use `git grep -n <pattern> HEAD -- <dir>`, "
        "`git ls-tree -r --name-only HEAD -- <dir>` and `git show HEAD:<path>`. "
        "Widen the checkout with `sparse-worktree add <dir>...`. Hooks widen it automatically when a "
        "tool reads or edits a tracked path outside the cone, or when a command fails with a "
        "missing-path / Bazel no-such-package error; they report what they added."
    ))


def hook_pre_tool_use(data: dict) -> None:
    tool = data.get("tool_name")
    tool_input = data.get("tool_input") or {}
    cwd = data.get("cwd") or os.getcwd()
    if tool == "Bash":
        command = tool_input.get("command", "")
        m = GIT_WORKTREE_ADD.match(command)
        if not m or "--no-checkout" in command:
            return
        roots = [toplevel(d) for d in command_dirs(cwd, command)[-1:]]
        if not roots[0] or not repo_settings(roots[0]):
            return
        new_input = dict(tool_input, command=f"{m.group(1)}sparse-worktree git{m.group(2)}")
        print(json.dumps({"hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "allow",
            "permissionDecisionReason": "sparse-worktree: worktree of a sparse-configured repo is created sparse",
            "updatedInput": new_input,
        }}))
        return
    key = FILE_TOOLS.get(tool)
    target = tool_input.get(key) if key else None
    if not target or os.path.exists(target):
        return
    top = toplevel(target)
    if not top or not is_sparse(top):
        return
    settings = repo_settings(top)
    rel = normalize(top, target)
    if not settings or not rel or in_cone(rel, cone_dirs(top)):
        return
    res = add_paths(top, [rel], settings["maxAutoAddFiles"])
    if res.added:
        print(f"sparse-worktree: added {' '.join(res.added)} to the sparse checkout of {top}", file=sys.stderr)


def hook_post_tool_use(data: dict, failure: bool) -> None:
    event = "PostToolUseFailure" if failure else "PostToolUse"
    tool = data.get("tool_name")
    tool_input = data.get("tool_input") or {}
    cwd = data.get("cwd") or os.getcwd()
    if tool == "Bash":
        command = tool_input.get("command", "")
        if failure:
            text = data.get("error") or ""
        else:
            resp = data.get("tool_response") or {}
            text = f"{resp.get('stdout', '')}\n{resp.get('stderr', '')}"
        if not MISSING_HINT.search(text):
            return
        dirs = command_dirs(cwd, command)
        roots = sparse_roots(dirs + [m.group(1) for m in ABS_PATH.finditer(text[:200000])][:200])
        emit(event, describe(fix_from_text(roots, text, base=dirs[-1])))
        return
    key = FILE_TOOLS.get(tool)
    target = tool_input.get(key) if key else None
    if not failure or not target or os.path.exists(target):
        return
    top = toplevel(target)
    if not top or not is_sparse(top) or not repo_settings(top):
        return
    rel = normalize(top, target)
    if not rel or in_cone(rel, cone_dirs(top)):
        return
    t = object_types(top, [rel]).get(rel)
    if not t:
        return
    res = add_paths(top, [rel], repo_settings(top)["maxAutoAddFiles"])
    emit(event, describe({top: {"added": res.added, "skipped": res.skipped, "reasons": [f"{tool} target"]}}))


def cmd_hook(event: str) -> None:
    data = json.load(sys.stdin)
    if event == "worktree-create":
        hook_worktree_create(data)
        return
    if event == "worktree-remove":
        hook_worktree_remove(data)
        return
    try:
        if event == "session-start":
            hook_session_start(data)
        elif event == "pre-tool-use":
            hook_pre_tool_use(data)
        elif event == "post-tool-use":
            hook_post_tool_use(data, failure=False)
        elif event == "post-tool-use-failure":
            hook_post_tool_use(data, failure=True)
    except Exception as e:  # a broken hook must never break the tool call it observes
        print(f"sparse-worktree hook {event}: {e}", file=sys.stderr)


# --- CLI -------------------------------------------------------------------------------------

def require_sparse_root(path: str) -> tuple[str, dict]:
    top = toplevel(path)
    if not top:
        sys.exit(f"sparse-worktree: {path} is not inside a git worktree")
    settings = repo_settings(top) or {"key": top, "dirs": [], "maxAutoAddFiles": DEFAULT_MAX_AUTO_ADD_FILES}
    return top, settings


def cmd_add(args: argparse.Namespace) -> None:
    top, settings = require_sparse_root(os.getcwd())
    if not is_sparse(top):
        sys.exit(f"sparse-worktree: {top} is not a sparse checkout")
    rels = [r for r in (normalize(top, p, base=os.getcwd()) for p in args.paths) if r]
    res = add_paths(top, rels, None if args.force else settings["maxAutoAddFiles"], force=args.force)
    for d, n in res.added.items():
        print(f"added {d} ({n} files)")
    for d, n in res.skipped.items():
        print(f"skipped {d} ({n} files > {settings['maxAutoAddFiles']}); use --force", file=sys.stderr)
    if not res.added and not res.skipped:
        print("nothing to add: paths are already in the cone or not tracked at HEAD")


def cmd_fix(args: argparse.Namespace) -> None:
    text = sys.stdin.read()
    roots = sparse_roots([os.getcwd()])
    out = describe(fix_from_text(roots, text, base=os.getcwd(), limit_override=args.limit))
    print(out or "sparse-worktree: no missing paths outside the sparse checkout found")


def cmd_convert(args: argparse.Namespace) -> None:
    top, settings = require_sparse_root(args.path)
    if not repo_settings(top):
        sys.exit(f"sparse-worktree: {settings['key']} is not configured for sparse worktrees")
    dirs = args.dirs or settings["dirs"]
    status = git_out("status", "--porcelain", "--untracked-files=no", cwd=top) or ""
    outside = [l[3:] for l in status.splitlines() if not in_cone(l[3:].split(" -> ")[-1], dirs)]
    if outside and not args.force:
        sys.exit("sparse-worktree: modified tracked files outside the new cone (commit, stash, "
                 "or pass their dirs via --dirs, or --force to keep them as-is):\n  " + "\n  ".join(outside))
    git("-c", "checkout.workers=0", "sparse-checkout", "set", "--cone", "--sparse-index", *dirs, cwd=top)
    res = close_symlinks(top, settings["maxAutoAddFiles"])
    print(f"{top}: sparse ({' '.join(cone_dirs(top))})" +
          (f"; followed symlinks into {' '.join(res.added)}" if res.added else ""))


def cmd_status(args: argparse.Namespace) -> None:
    top = toplevel(args.path)
    if not top:
        sys.exit(f"sparse-worktree: {args.path} is not inside a git worktree")
    settings = repo_settings(top)
    print(f"worktree:   {top}")
    print(f"configured: {settings['key'] if settings else 'no'}")
    print(f"sparse:     {'yes' if is_sparse(top) else 'no'}")
    if is_sparse(top):
        print(f"cone:       {' '.join(cone_dirs(top))}")


def main(argv: list[str] | None = None) -> None:
    argv = sys.argv[1:] if argv is None else argv
    if argv[:1] == ["git"]:
        cmd_git(argv[1:])
        return
    p = argparse.ArgumentParser(prog="sparse-worktree", description=__doc__.splitlines()[0])
    sub = p.add_subparsers(dest="cmd", required=True)
    s = sub.add_parser("add", help="add directories (or the directories of paths) to the sparse checkout")
    s.add_argument("paths", nargs="+")
    s.add_argument("--force", action="store_true", help="ignore the auto-add size limit")
    s.set_defaults(func=cmd_add)
    s = sub.add_parser("fix", help="read error output on stdin and add the missing directories it names")
    s.add_argument("--limit", type=int, help="override the per-repo size limit")
    s.set_defaults(func=cmd_fix)
    s = sub.add_parser("convert", help="make an existing full worktree sparse")
    s.add_argument("path", nargs="?", default=".")
    s.add_argument("--dirs", nargs="+", help="cone directories (default: the repo's configured dirs)")
    s.add_argument("--force", action="store_true")
    s.set_defaults(func=cmd_convert)
    s = sub.add_parser("status", help="show whether a worktree is sparse and its cone")
    s.add_argument("path", nargs="?", default=".")
    s.set_defaults(func=cmd_status)
    s = sub.add_parser("hook", help="Claude Code hook entry point (reads the hook JSON on stdin)")
    s.add_argument("event", choices=["session-start", "pre-tool-use", "post-tool-use", "post-tool-use-failure",
                                      "worktree-create", "worktree-remove"])
    s.set_defaults(func=lambda a: cmd_hook(a.event))
    sub.add_parser("git", help="git wrapper: `worktree add` in a configured repo creates a sparse worktree")
    args = p.parse_args(argv)
    args.func(args)


if __name__ == "__main__":
    main()
