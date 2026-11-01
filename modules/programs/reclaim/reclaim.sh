SM=${RECLAIM_STORY_MANAGER:-swm}

usage() {
  cat <<EOF
Usage: reclaim [-n|--dry-run] [-y|--yes] [--only STEP]... [--skip STEP]... [STORY]...

With STORY arguments, only those stories are considered for removal.

Reclaim disk space: prune finished $SM stories, then Docker, Bazel, git and .terraform caches.

Steps (all run by default, in this order):
  stories        remove $SM stories whose every worktree is clean and landed
  docker         prune containers, images, build cache, networks and volumes
  bazel          remove orphaned output bases, the repository cache and old installs
  bazel-expunge  run 'bazel clean --expunge' in every live Bazel workspace
  git            'git worktree prune' and 'git gc --prune=now' in every canonical clone
  terraform      delete .terraform directories under the $SM code root

A story is done when, for each of its worktrees (including nested ones such as
.claude/worktrees), there are no uncommitted changes and HEAD is either already in the
default branch or is the head of a merged/closed GitHub PR for its branch. Story dirs
$SM no longer tracks are checked the same way. Stories with an attached tmux client or
a process working inside them (other than idle shells and daemons) are skipped.

Options:
  -n, --dry-run  show what would be done without changing anything
  -y, --yes      remove done stories without asking
  -h, --help     show this help
EOF
}

ALL_STEPS=(stories docker bazel bazel-expunge git terraform)
DRY_RUN=0
ASSUME_YES=0
only=()
skip=()
stories=()

while (($#)); do
  case $1 in
    -n | --dry-run) DRY_RUN=1 ;;
    -y | --yes) ASSUME_YES=1 ;;
    --only) only+=("$2"); shift ;;
    --skip) skip+=("$2"); shift ;;
    -h | --help) usage; exit 0 ;;
    -*) echo "unknown argument: $1" >&2; usage >&2; exit 2 ;;
    *) stories+=("$1") ;;
  esac
  shift
done

for s in "${only[@]}" "${skip[@]}"; do
  [[ " ${ALL_STEPS[*]} " == *" $s "* ]] || { echo "unknown step: $s" >&2; exit 2; }
done

enabled() {
  local s
  if ((${#only[@]})); then
    for s in "${only[@]}"; do [[ $s == "$1" ]] && return 0; done
    return 1
  fi
  for s in "${skip[@]}"; do [[ $s == "$1" ]] && return 1; done
  return 0
}

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[33m%s\033[0m\n' "$*" >&2; }
run() {
  echo "+ $*"
  ((DRY_RUN)) || "$@" || echo "  (failed, continuing)"
}

confirm() {
  ((ASSUME_YES)) && return 0
  ((DRY_RUN)) && return 0
  [[ -r /dev/tty ]] || { warn "no tty to confirm on; pass --yes"; return 1; }
  local reply
  read -r -p "$1 [y/N] " reply </dev/tty
  [[ $reply == [yY] || $reply == [yY][eE][sS] ]]
}

sm_config() { "$SM" config get "$1" 2>&1 | tail -n 1; }

IS_DARWIN=0
[[ $(uname -s) == Darwin ]] && IS_DARWIN=1

CODE_ROOT=${CODE_PATH:-$(sm_config code_root)}
DEFAULT_STORY=$(sm_config default_story)
[[ -d $CODE_ROOT ]] || { echo "$SM code root '$CODE_ROOT' is not a directory" >&2; exit 1; }
STORIES_DIR="$CODE_ROOT/stories"

# $SM keeps its tmux sockets in adrg/xdg's runtime dir, which falls back to
# ~/Library/Application Support on macOS and /run/user/UID on Linux.
if [[ -n ${XDG_RUNTIME_DIR:-} ]]; then
  TMUX_SOCKET_DIR="$XDG_RUNTIME_DIR/$SM/tmux"
elif ((IS_DARWIN)); then
  TMUX_SOCKET_DIR="$HOME/Library/Application Support/$SM/tmux"
else
  TMUX_SOCKET_DIR="/run/user/$(id -u)/$SM/tmux"
fi

if [[ -n ${BAZEL_OUTPUT_USER_ROOT:-} ]]; then
  BAZEL_ROOT=$BAZEL_OUTPUT_USER_ROOT
elif ((IS_DARWIN)); then
  BAZEL_ROOT="/private/var/tmp/_bazel_$USER"
else
  BAZEL_ROOT="$HOME/.cache/bazel/_bazel_$USER"
fi

repo_slug() {
  local url
  url=$(git -C "$1" remote get-url origin 2>/dev/null) || return 1
  url=${url%.git}
  url=${url#*://}
  url=${url#*@}
  echo "${url/://}"
}

default_ref() {
  local ref
  for ref in "$(git -C "$1" rev-parse --abbrev-ref origin/HEAD 2>/dev/null)" origin/main origin/master; do
    [[ -n $ref ]] && git -C "$1" rev-parse -q --verify "$ref^{commit}" >/dev/null && { echo "$ref"; return 0; }
  done
  return 1
}

worktree_done() {
  local wt=$1 base branch slug prs pr head num state oid nested status_args=()
  git -C "$wt" rev-parse --git-dir >/dev/null 2>&1 || { REASON="broken worktree"; return 1; }
  while IFS= read -r nested; do
    status_args+=(":(exclude)${nested#"$wt"/}")
  done < <(find "$wt" -mindepth 2 -maxdepth 4 -name .git -type f -printf '%h\n' 2>/dev/null)
  ((${#status_args[@]})) && status_args=(--untracked-files=all -- . "${status_args[@]}")
  if [[ -n $(git -C "$wt" status --porcelain "${status_args[@]}" 2>/dev/null) ]]; then
    REASON="uncommitted changes"
    return 1
  fi
  base=$(default_ref "$wt") || { REASON="no default branch to compare against"; return 1; }
  if git -C "$wt" merge-base --is-ancestor HEAD "$base"; then
    REASON="nothing beyond $base"
    return 0
  fi
  if ! git -C "$wt" cherry "$base" HEAD | grep -q '^+'; then
    REASON="all commits already in $base"
    return 0
  fi
  branch=$(git -C "$wt" symbolic-ref --short -q HEAD) || { REASON="detached HEAD with unmerged commits"; return 1; }
  slug=$(repo_slug "$wt") || { REASON="no origin remote"; return 1; }
  # Only GitHub PRs can be looked up; a squash-merged branch elsewhere is kept.
  [[ $slug == github.com/* ]] || { REASON="unmerged commits; no PR lookup outside GitHub ($slug)"; return 1; }
  prs=$(gh pr list -R "$slug" --head "$branch" --state all --json number,state,headRefOid 2>/dev/null) || {
    REASON="unmerged commits; PR lookup on $slug failed"
    return 1
  }
  if [[ $(jq '[.[] | select(.state == "OPEN")] | length' <<<"$prs") != 0 ]]; then
    REASON="open PR #$(jq -r '[.[] | select(.state == "OPEN")][0].number' <<<"$prs")"
    return 1
  fi
  pr=$(jq -r 'sort_by(.number) | last | select(.) | "\(.number) \(.state) \(.headRefOid)"' <<<"$prs")
  [[ -n $pr ]] || { REASON="unmerged commits and no PR"; return 1; }
  read -r num state oid <<<"$pr"
  head=$(git -C "$wt" rev-parse HEAD)
  if [[ $head == "$oid" ]] || git -C "$wt" merge-base --is-ancestor HEAD "$oid" 2>/dev/null; then
    REASON="PR #$num ${state,,}"
    return 0
  fi
  REASON="commits after PR #$num (${state,,})"
  return 1
}

story_worktrees() {
  find "$1" -maxdepth 7 -name node_modules -prune -o -name .git -type f -printf '%d %h\n' 2>/dev/null |
    sort -rn | cut -d' ' -f2-
}

# Every process's working directory, as "pid<TAB>ppid<TAB>comm<TAB>cwd": from
# /proc on Linux, from lsof and ps where there is no /proc (macOS).
proc_cwds() {
  local cwd pid
  if [[ -d /proc/self ]]; then
    for cwd in /proc/[0-9]*/cwd; do
      pid=${cwd#/proc/}
      pid=${pid%/cwd}
      cwd=$(readlink "$cwd" 2>/dev/null) || continue
      printf '%s\t%s\t%s\t%s\n' "$pid" \
        "$(awk '/^PPid:/ { print $2 }' "/proc/$pid/status" 2>/dev/null)" \
        "$(<"/proc/$pid/comm")" "$cwd"
    done 2>/dev/null
  elif command -v lsof >/dev/null; then
    awk -F'\t' -v OFS='\t' '
      NR == FNR { ppid[$1] = $2; next }
      /^p/ { pid = substr($0, 2) }
      /^c/ { comm = substr($0, 2) }
      /^n/ { print pid, ppid[pid], comm, substr($0, 2) }
    ' <(ps -A -o pid=,ppid= | awk -v OFS='\t' '{ print $1, $2 }') \
      <(lsof -nP +c 0 -d cwd -Fpcn 2>/dev/null)
  fi
}

story_busy() {
  local name=$1 dir=$2 sock="$TMUX_SOCKET_DIR/$1.sock" real pid ppid comm cwd
  if [[ -S $sock ]] && [[ -n $(tmux -S "$sock" list-clients 2>/dev/null) ]]; then
    REASON="tmux client attached"
    return 0
  fi
  real=$(realpath "$dir" 2>/dev/null) || real=$dir
  [[ $PWD == "$dir" || $PWD == "$dir"/* || $PWD == "$real" || $PWD == "$real"/* ]] && {
    REASON="current directory"
    return 0
  }
  while IFS=$'\t' read -r pid ppid comm cwd; do
    [[ $cwd == "$dir" || $cwd == "$dir"/* || $cwd == "$real" || $cwd == "$real"/* ]] || continue
    comm=${comm#-}
    comm=${comm##*/}
    [[ $ppid == 1 || $comm == java || $comm == bazel* ]] && continue
    [[ $comm == zsh || $comm == bash || $comm == sh || $comm == fish ]] && continue
    REASON="in use by $comm (pid $pid)"
    return 0
  done < <(proc_cwds)
  return 1
}

main_repo() {
  local common
  common=$(git -C "$1" rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || return 1
  echo "${common%/.git}"
}

prune_stories() {
  local dir name wt kept=() done_stories=() done_reasons=()
  [[ -d $STORIES_DIR ]] || { echo "no $STORIES_DIR"; return; }
  for dir in "$STORIES_DIR"/*/; do
    dir=${dir%/}
    name=${dir##*/}
    [[ $name == "$DEFAULT_STORY" ]] && continue
    ((${#stories[@]})) && [[ " ${stories[*]} " != *" $name "* ]] && continue
    local ok=1 why=()
    while IFS= read -r wt; do
      if worktree_done "$wt"; then
        why+=("${wt#"$dir"/}: $REASON")
      else
        kept+=("$name: ${wt#"$dir"/}: $REASON")
        ok=0
        break
      fi
    done < <(story_worktrees "$dir")
    ((ok)) || continue
    if ((${#why[@]} == 0)) && [[ -n $(find "$dir" -mindepth 1 ! -type d -print -quit 2>/dev/null) ]]; then
      kept+=("$name: $(du -sh "$dir" 2>/dev/null | cut -f1) of files but no git worktree to verify; inspect and delete by hand")
      continue
    fi
    if story_busy "$name" "$dir"; then
      kept+=("$name: done, but $REASON")
      continue
    fi
    done_stories+=("$name")
    done_reasons+=("$(printf '    %s\n' "${why[@]:-no worktrees left}")")
  done

  if ((${#kept[@]})); then
    echo "Keeping:"
    printf '  %s\n' "${kept[@]}"
  fi
  if ((${#done_stories[@]} == 0)); then
    echo "No done stories."
    return
  fi
  echo "Done:"
  local i
  for i in "${!done_stories[@]}"; do
    echo "  ${done_stories[i]}"
    echo "${done_reasons[i]}"
  done
  confirm "Remove ${#done_stories[@]} done stories?" || return

  local tracked repo branch branches
  for name in "${done_stories[@]}"; do
    dir="$STORIES_DIR/$name"
    # The worktrees $SM records for the story; it removes those itself.
    tracked=$("$SM" story show --json "$name" 2>/dev/null) || tracked=
    branches=()
    while IFS= read -r wt; do
      repo=$(main_repo "$wt") || continue
      branch=$(git -C "$wt" symbolic-ref --short -q HEAD) && branches+=("$repo $branch")
      if [[ -n $tracked ]] && jq -e --arg p "$wt" 'any(.projects[]; .worktree_path == $p)' <<<"$tracked" >/dev/null; then
        continue
      fi
      run git -C "$repo" worktree remove --force "$wt"
    done < <(story_worktrees "$dir")
    [[ -n $tracked ]] && run "$SM" story remove --force "$name"
    for branch in "${branches[@]}"; do
      run git -C "${branch%% *}" branch -D "${branch#* }"
    done
    ((DRY_RUN)) && continue
    find "$dir" -depth -type d -empty -delete 2>/dev/null
    [[ -e $dir ]] && warn "  $dir still has files left; inspect and delete it by hand"
  done
}

prune_docker() {
  if ! command -v docker >/dev/null || ! docker info >/dev/null 2>&1; then
    echo "docker not running, skipping"
    return
  fi
  docker system df
  run docker container prune -f
  run docker image prune -a -f
  run docker builder prune -a -f
  run docker network prune -f
  run docker volume prune -a -f
}

prune_bazel() {
  local base ws pid
  [[ -d $BAZEL_ROOT ]] || { echo "no $BAZEL_ROOT"; return; }
  for base in "$BAZEL_ROOT"/*/; do
    base=${base%/}
    [[ -f $base/DO_NOT_BUILD_HERE ]] || continue
    ws=$(<"$base/DO_NOT_BUILD_HERE")
    [[ -d $ws ]] && continue
    echo "workspace $ws gone ($(du -sh "$base" 2>/dev/null | cut -f1))"
    if [[ -f $base/server/server.pid.txt ]]; then
      pid=$(<"$base/server/server.pid.txt")
      kill -0 "$pid" 2>/dev/null && run kill "$pid"
    fi
    run chmod -R u+w "$base"
    run rm -rf "$base"
  done

  run rm -rf "$BAZEL_ROOT/cache/repos"
  if [[ -d $BAZEL_ROOT/install ]]; then
    local d
    while IFS= read -r d; do
      run chmod -R u+w "$BAZEL_ROOT/install/$d"
      run rm -rf "${BAZEL_ROOT:?}/install/$d"
    done < <(find "$BAZEL_ROOT/install" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %f\n' | sort -rn | tail -n +3 | cut -d' ' -f2-)
  fi
}

expunge_bazel() {
  local marker ws
  command -v bazel >/dev/null || { echo "bazel not on PATH, skipping"; return; }
  for marker in "$BAZEL_ROOT"/*/DO_NOT_BUILD_HERE; do
    [[ -f $marker ]] || continue
    ws=$(<"$marker")
    [[ -d $ws ]] || continue
    echo "in $ws"
    (cd "$ws" && run bazel clean --expunge)
  done
}

gc_git() {
  local gitdir repo
  while IFS= read -r gitdir; do
    repo=${gitdir%/.git}
    run git -C "$repo" worktree prune
    run git -C "$repo" gc --prune=now
  done < <(find "$CODE_ROOT/repositories" -mindepth 2 -maxdepth 8 -name .git -type d -prune 2>/dev/null)
}

prune_terraform() {
  local dir
  while IFS= read -r -d '' dir; do
    du -sh "$dir"
    run rm -rf "$dir"
  done < <(find "$CODE_ROOT" \( -name .git -o -name node_modules \) -prune -o -type d -name .terraform -prune -print0 2>/dev/null)
}

avail() {
  df --output=target "$HOME" "$CODE_ROOT" "$BAZEL_ROOT" 2>/dev/null | tail -n +2 | sort -u |
    xargs -r -d '\n' df --output=avail -B1 | awk 'NR > 1 { s += $1 } END { print s + 0 }'
}

((DRY_RUN)) && echo "Dry run: nothing will be changed."
before=$(avail)

enabled stories && { step "$SM stories under $STORIES_DIR"; prune_stories; }
enabled docker && { step "Docker"; prune_docker; }
enabled bazel && { step "Bazel orphaned output bases, repository cache and old installs"; prune_bazel; }
enabled bazel-expunge && { step "Bazel clean --expunge"; expunge_bazel; }
enabled git && { step "git gc"; gc_git; }
enabled terraform && { step ".terraform directories under $CODE_ROOT"; prune_terraform; }

after=$(avail)
step "Done"
df -h "$HOME" | tail -1
((DRY_RUN)) || echo "Freed: $(numfmt --to=iec -- $((after - before)))"
