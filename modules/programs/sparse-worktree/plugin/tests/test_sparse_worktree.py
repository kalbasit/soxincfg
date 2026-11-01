import io
import json
import os
import subprocess
import sys
import tempfile
import unittest
from contextlib import redirect_stdout
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "lib"))

import sparse_worktree as sw  # noqa: E402

FAKE_URL = "git@example.com:org/big.git"


def run(*args, cwd=None):
    return subprocess.run(args, cwd=cwd, check=True, capture_output=True, text=True).stdout


class Fixture(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.home = self.root / "home"
        self.home.mkdir()
        os.environ["HOME"] = str(self.home)
        os.environ["GIT_CONFIG_GLOBAL"] = str(self.home / ".gitconfig")
        os.environ["GIT_CONFIG_NOSYSTEM"] = "1"
        run("git", "config", "--global", "user.email", "t@example.com")
        run("git", "config", "--global", "user.name", "t")
        run("git", "config", "--global", "init.defaultBranch", "master")
        self.config = self.root / "config.json"
        self.config.write_text(json.dumps({"repos": {"example.com/org/big": {"dirs": ["a", "tools"],
                                                                             "maxAutoAddFiles": 10}}}))
        os.environ["SPARSE_WORKTREE_CONFIG"] = str(self.config)
        src = self.root / "src"
        for rel, content in {"top.txt": "t", "a/BUILD": "", "a/x.txt": "x", "scripts/launch": "#!/bin/sh",
                             "c/d/e.txt": "e", "c/other.txt": "o"}.items():
            (src / rel).parent.mkdir(parents=True, exist_ok=True)
            (src / rel).write_text(content)
        for i in range(30):
            (src / "big" / f"f{i}.txt").parent.mkdir(parents=True, exist_ok=True)
            (src / "big" / f"f{i}.txt").write_text(str(i))
        (src / "tools").mkdir()
        os.symlink("../scripts/launch", src / "tools" / "bazel")
        run("git", "init", "-q", cwd=src)
        run("git", "add", "-A", cwd=src)
        run("git", "commit", "-qm", "init", cwd=src)
        bare = self.root / "origin.git"
        run("git", "clone", "-q", "--bare", str(src), str(bare))
        self.repo = self.root / "repo"
        run("git", "clone", "-q", str(bare), str(self.repo))
        run("git", "remote", "set-url", "origin", FAKE_URL, cwd=self.repo)
        run("git", "config", f"url.{bare}.insteadOf", FAKE_URL, cwd=self.repo)

    def tearDown(self):
        self.tmp.cleanup()

    def sparse_worktree(self, name="wt"):
        path = self.root / name
        sw.create_sparse(str(self.repo), ["-b", name, str(path)], sw.repo_settings(str(self.repo)), quiet=True)
        return path


class ParseTest(unittest.TestCase):
    def test_parse_remote(self):
        self.assertEqual(sw.parse_remote("git@git.example.com:org/monorepo.git"), "git.example.com/org/monorepo")
        self.assertEqual(sw.parse_remote("https://git.example.com/org/monorepo.git"),
                         "git.example.com/org/monorepo")
        self.assertEqual(sw.parse_remote("ssh://git@git.example.com:7999/org/monorepo"),
                         "git.example.com/org/monorepo")
        self.assertIsNone(sw.parse_remote("/local/path/repo.git"))

    def test_worktree_add_path(self):
        self.assertEqual(sw.worktree_add_path(["-b", "br", "/p", "origin/master"]), "/p")
        self.assertEqual(sw.worktree_add_path(["--detach", "-q", "/p"]), "/p")
        self.assertEqual(sw.worktree_add_path(["--reason", "x", "--lock", "/p", "br"]), "/p")

    def test_extract_candidates_real_bazel_errors(self):
        text = "\n".join([
            "ERROR: Bazelisk did not return a path for Bazel. Is there a file at tools/bazel? Output from Bazelisk:",
            "[FATAL 22:32:40.048 src/main/cpp/blaze.cc:1238] Nonexistent path in import declaration in config file "
            "'/w/.bazelrc': 'import %workspace%/build/flags/.bazelrc.extra' (are you in your source checkout/WORKSPACE?)",
            "ERROR: Error computing the main repository mapping: Label '//third_party/external/bazel_skylib:workspace.bzl' "
            "is invalid because 'third_party/external/bazel_skylib' is not a package; perhaps you meant ...",
            "ERROR: no such package 'services/planner': BUILD file not found in any of the following directories.",
            "ERROR: error loading package '': cannot load '@@//tools/build_rules:py.bzl': no such file",
            "ERROR: no such package '@@rules_go//go': not relevant",
        ])
        got = {c for c, _ in sw.extract_candidates(text)}
        for want in ("tools/bazel", "build/flags/.bazelrc.extra", "third_party/external/bazel_skylib",
                     "services/planner", "tools/build_rules"):
            self.assertIn(want, got)
        self.assertNotIn("rules_go//go", got)

    def test_extract_git_pathspec_warning(self):
        text = ("The following paths and/or pathspecs matched paths that exist\n"
                "outside of your sparse-checkout definition, so will not be\nupdated in the index:\n"
                "c/d/e.txt\nhint: If you intend to update such entries...")
        self.assertIn(("c/d/e.txt", "git pathspec outside sparse checkout"), sw.extract_candidates(text))


class SparseTest(Fixture):
    def test_git_shim_creates_sparse_worktree_and_follows_symlinks(self):
        path = self.sparse_worktree()
        self.assertTrue((path / "a" / "x.txt").exists())
        self.assertTrue((path / "top.txt").exists())
        self.assertFalse((path / "big").exists())
        self.assertTrue((path / "tools" / "bazel").exists(), "symlink target dir should be auto-added")
        self.assertEqual(sw.cone_dirs(str(path)), ["a", "scripts", "tools"])
        self.assertEqual(run("git", "branch", "--show-current", cwd=path).strip(), "wt")
        self.assertFalse((self.repo / ".git" / "config.worktree").exists() and
                         "sparseCheckout" in (self.repo / ".git" / "config.worktree").read_text())

    def test_unconfigured_repo_gets_full_checkout(self):
        self.config.write_text(json.dumps({"repos": {}}))
        path = self.root / "full"
        r = subprocess.run([sys.executable, sw.__file__, "git", "-C", str(self.repo), "worktree", "add", "-q",
                            str(path)], capture_output=True, text=True)
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertTrue((path / "big" / "f1.txt").exists())
        self.assertFalse(sw.is_sparse(str(path)))

    def test_fix_adds_package_dir_and_respects_limit(self):
        path = str(self.sparse_worktree())
        report = sw.fix_from_text([path], "ERROR: no such package 'c/d': BUILD file not found\n"
                                          "cat: big/f1.txt: No such file or directory", base=path)
        self.assertEqual(report[path]["added"], {"c/d": 1})
        self.assertEqual(report[path]["skipped"], {"big": 30})
        self.assertTrue(Path(path, "c", "d", "e.txt").exists())
        self.assertFalse(Path(path, "big").exists())
        self.assertIn("too big", sw.describe(report))

    def test_fix_ignores_untracked_and_in_cone_paths(self):
        path = str(self.sparse_worktree())
        self.assertEqual(sw.fix_from_text([path], "cat: a/nope.txt: No such file or directory\n"
                                                  "cat: zz/nope.txt: No such file or directory", base=path), {})

    def test_pre_tool_use_read_adds_dir(self):
        path = self.sparse_worktree()
        sw.hook_pre_tool_use({"tool_name": "Read", "cwd": str(path),
                              "tool_input": {"file_path": str(path / "c" / "other.txt")}})
        self.assertTrue((path / "c" / "other.txt").exists())

    def test_pre_tool_use_rewrites_git_worktree_add(self):
        buf = io.StringIO()
        with redirect_stdout(buf):
            sw.hook_pre_tool_use({"tool_name": "Bash", "cwd": str(self.repo),
                                  "tool_input": {"command": "git worktree add -b x ../x origin/master",
                                                 "description": "d"}})
        out = json.loads(buf.getvalue())["hookSpecificOutput"]
        self.assertEqual(out["updatedInput"]["command"], "sparse-worktree git worktree add -b x ../x origin/master")
        self.assertEqual(out["updatedInput"]["description"], "d")

    def test_pre_tool_use_leaves_compound_commands_alone(self):
        buf = io.StringIO()
        with redirect_stdout(buf):
            sw.hook_pre_tool_use({"tool_name": "Bash", "cwd": str(self.repo),
                                  "tool_input": {"command": "git worktree add ../x && rm -rf ../y"}})
        self.assertEqual(buf.getvalue(), "")

    def test_post_tool_use_failure_reports_context(self):
        path = self.sparse_worktree()
        buf = io.StringIO()
        with redirect_stdout(buf):
            sw.hook_post_tool_use({"tool_name": "Bash", "cwd": str(path), "tool_input": {"command": "bazel build //c/d"},
                                   "error": "Exit code 1\nERROR: no such package 'c/d': BUILD file not found"},
                                  failure=True)
        ctx = json.loads(buf.getvalue())["hookSpecificOutput"]
        self.assertEqual(ctx["hookEventName"], "PostToolUseFailure")
        self.assertIn("`c/d`", ctx["additionalContext"])

    def test_session_start_context_only_in_sparse_worktree(self):
        path = self.sparse_worktree()
        buf = io.StringIO()
        with redirect_stdout(buf):
            sw.hook_session_start({"cwd": str(self.repo)})
            self.assertEqual(buf.getvalue(), "")
            sw.hook_session_start({"cwd": str(path)})
        self.assertIn("sparse git worktree", json.loads(buf.getvalue())["hookSpecificOutput"]["additionalContext"])

    def test_convert_refuses_modified_files_outside_cone(self):
        self.config.write_text(json.dumps({"repos": {}}))
        path = self.root / "conv"
        run("git", "-C", str(self.repo), "worktree", "add", "-q", str(path))
        self.config.write_text(json.dumps({"repos": {"example.com/org/big": {"dirs": ["a"]}}}))
        (path / "big" / "f1.txt").write_text("changed")
        args = type("A", (), {"path": str(path), "dirs": None, "force": False})
        with self.assertRaises(SystemExit):
            sw.cmd_convert(args)
        run("git", "checkout", "--", "big/f1.txt", cwd=path)
        with redirect_stdout(io.StringIO()):
            sw.cmd_convert(args)
        self.assertFalse((path / "big").exists())
        self.assertTrue(sw.is_sparse(str(path)))


class ClaudeWorktreeHookTest(Fixture):
    def setUp(self):
        super().setUp()
        self.saved_project_dir = os.environ.pop("CLAUDE_PROJECT_DIR", None)

    def tearDown(self):
        if self.saved_project_dir is not None:
            os.environ["CLAUDE_PROJECT_DIR"] = self.saved_project_dir
        super().tearDown()

    def worktree_create(self, name, transcript=None):
        buf = io.StringIO()
        data = {"name": name, "cwd": str(self.repo)}
        if transcript:
            data["transcript_path"] = str(transcript)
        with redirect_stdout(buf):
            sw.hook_worktree_create(data)
        return Path(buf.getvalue().strip().splitlines()[-1])

    def transcript(self, *cwds):
        t = self.root / "session.jsonl"
        t.write_text("".join(json.dumps({"type": "user", "cwd": c}) + "\n" for c in cwds))
        return t

    def story_worktree(self):
        story = self.root / "stories" / "S" / "repo"
        run("git", "-C", str(self.repo), "worktree", "add", "-q", "-b", "user/S", str(story))
        return story

    def test_session_started_in_story_worktree_nests_under_it_via_transcript(self):
        story = self.story_worktree()
        path = self.worktree_create("j1", self.transcript(str(story), str(story / "a"), str(self.repo)))
        self.assertEqual(path, story / ".claude" / "worktrees" / "j1")
        self.assertTrue(sw.is_sparse(str(path)))

    def test_session_started_in_story_worktree_via_project_dir(self):
        story = self.story_worktree()
        os.environ["CLAUDE_PROJECT_DIR"] = str(story)
        self.assertEqual(self.worktree_create("j2"), story / ".claude" / "worktrees" / "j2")

    def test_canonical_session_and_claude_worktrees_stay_in_canonical(self):
        nested = self.worktree_create("old")
        path = self.worktree_create("j3", self.transcript(str(self.repo), str(nested)))
        self.assertEqual(path, self.repo / ".claude" / "worktrees" / "j3")

    def test_configured_repo_gets_sparse_worktree_on_default_branch(self):
        path = self.worktree_create("job1")
        self.assertEqual(path, self.repo / ".claude" / "worktrees" / "job1")
        self.assertTrue(sw.is_sparse(str(path)))
        self.assertEqual(run("git", "branch", "--show-current", cwd=path).strip(), "worktree-job1")

    def test_unconfigured_repo_gets_default_full_worktree(self):
        self.config.write_text(json.dumps({"repos": {}}))
        path = self.worktree_create("job2")
        self.assertFalse(sw.is_sparse(str(path)))
        self.assertTrue((path / "big" / "f1.txt").exists())

    def test_remove_deletes_merged_branch_but_keeps_unmerged(self):
        merged = self.worktree_create("m")
        sw.hook_worktree_remove({"worktree_path": str(merged)})
        self.assertFalse(merged.exists())
        self.assertEqual(run("git", "branch", "--list", "worktree-m", cwd=self.repo), "")
        work = self.worktree_create("w")
        (work / "a" / "new.txt").write_text("n")
        run("git", "add", "a/new.txt", cwd=work)
        run("git", "commit", "-qm", "work", cwd=work)
        sw.hook_worktree_remove({"worktree_path": str(work)})
        self.assertFalse(work.exists())
        self.assertIn("worktree-w", run("git", "branch", "--list", "worktree-w", cwd=self.repo))


if __name__ == "__main__":
    unittest.main()
