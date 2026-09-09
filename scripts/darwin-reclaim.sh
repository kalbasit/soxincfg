#! /usr/bin/env bash
#
# darwin-reclaim.sh - reclaim disk space on a nix-darwin host.
#
# Only touches data that is regenerable (nix store, caches) or already dead
# (an idle Docker Desktop VM disk). Never touches user documents, code, or
# downloads - those need human triage, not a script.
#
# USAGE
#   darwin-reclaim.sh                     dry run; prints what it would do
#   darwin-reclaim.sh --apply             do it
#   darwin-reclaim.sh --apply --dev-caches       also npm/pnpm/bun/gradle/go
#   darwin-reclaim.sh --apply --thin-snapshots   also drop local TM snapshots
#   darwin-reclaim.sh --measure           exact nix store size (SLOW, minutes)
#
# READ THIS FIRST - why "I deleted 30 GB and nothing was freed"
#   APFS keeps Time Machine *local* snapshots on the internal disk. Blocks
#   referenced by a snapshot are not released when you delete the file, so
#   deletions appear to free nothing until the snapshots aging out or are
#   thinned. If your Time Machine destination is a network share you are
#   currently away from, snapshots accumulate and free space quietly vanishes.
#   This script reports snapshot count always, and only removes them when you
#   pass --thin-snapshots.
#
set -euo pipefail

readonly KEEP_GENERATIONS=3

APPLY=0
MEASURE=0
DEV_CACHES=0
THIN_SNAPSHOTS=0

usage() {
    sed -n '3,28p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
    exit "${1:-0}"
}

for arg in "${@}"; do
    case "${arg}" in
        --apply)            APPLY=1 ;;
        --measure)          MEASURE=1 ;;
        --dev-caches)       DEV_CACHES=1 ;;
        --thin-snapshots)   THIN_SNAPSHOTS=1 ;;
        -h|--help)          usage 0 ;;
        *) >&2 echo "FATAL: unknown option: ${arg}"; usage 1 ;;
    esac
done

isDarwin() {
    local os
    os="$(uname -s)"
    [[ "${os}" == "Darwin" ]]
}

if ! isDarwin; then
    >&2 echo "FATAL: this script is for Darwin hosts only."
    exit 1
fi

warn() { >&2 echo "  ! ${*}"; }

# Echo a command, and run it only when applying. Failure is never fatal: a
# cleanup script should keep going and report, not abort halfway through.
run() {
    echo "  \$ ${*}"
    if [[ "${APPLY}" -eq 1 ]]; then
        "${@}" || warn "failed (continuing): ${1}"
    fi
}

# Free space on / in GB. Instant - df does not walk the tree.
avail() { df -k / | awk 'NR==2{printf "%.1f", $4/1048576}'; }

# Size of a path in GB. On a directory this walks the whole tree and can take
# minutes; callers print a progress line first.
sizeof() {
    if [[ -e "${1}" ]]; then
        du -x -s -k "${1}" 2>/dev/null | awk '{printf "%.1f", $1/1048576}'
    else
        echo "0.0"
    fi
}

# Last-modified time, portable across GNU and BSD stat. GNU coreutils is often
# ahead of /usr/bin on a nix host, and there -f means "filesystem info", not
# "format". Try GNU's -c first, then BSD's -f. Capture rather than pipe: a
# pipeline's status comes from the last command, so `stat ... | cut` would look
# successful even when stat failed and printed nothing.
mtime_of() {
    local out
    if out="$(stat -c '%y' "${1}" 2>/dev/null)" && [[ -n "${out}" ]]; then
        echo "${out%%.*}"          # GNU: 2026-04-29 23:13:51.000000000 +0000
        return 0
    fi
    if out="$(stat -f '%Sm' "${1}" 2>/dev/null)" && [[ -n "${out}" ]]; then
        echo "${out}"              # BSD
        return 0
    fi
    echo "unknown"
}

# Delete the *contents* of a directory, never the directory: some apps expect
# the parent to exist and will not recreate it.
clear_contents() {
    local d="${1}" label size
    [[ -d "${d}" ]] || return 0
    label="$(basename "${d}")"

    echo "    ${label}: measuring..."
    size="$(sizeof "${d}")"
    if [[ "${size}" == "0.0" ]]; then
        echo "    ${label}: already empty, skipping"
        return 0
    fi

    echo "    ${label}: ${size} GB"
    if [[ "${APPLY}" -eq 1 ]]; then
        find "${d}" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true
        echo "    ${label}: cleared"
    else
        echo "  \$ find ${d} -mindepth 1 -maxdepth 1 -exec rm -rf {} +"
    fi
}

# --- safety: decrypted sops secrets are off limits ---------------------------
for guard in "${HOME}/.config/sops-nix" "${HOME}/.config/sops" "${HOME}/.local/share/sops"; do
    case " ${*} " in *"${guard}"*) >&2 echo "FATAL: sops path passed as argument"; exit 1 ;; esac
done

if [[ "${APPLY}" -eq 0 ]]; then
    echo "=============================================="
    echo " DRY RUN - nothing will be deleted."
    echo " Re-run with --apply to execute."
    echo "=============================================="
else
    echo "=============================================="
    echo " APPLYING - this will delete data."
    echo "=============================================="
fi

BEFORE_ROOT="$(avail)"
readonly BEFORE_ROOT
echo
echo "free space at start: ${BEFORE_ROOT} GB"

BEFORE_NIX="(not measured)"
if [[ "${MEASURE}" -eq 1 ]]; then
    echo "measuring nix store (slow, several minutes)..."
    BEFORE_NIX="$(sizeof /nix/store) GB"
    echo "  nix store: ${BEFORE_NIX}"
fi

# =============================================================================
# 0. APFS local snapshots - report first, because they mask everything below
# =============================================================================
echo
echo "### 0. APFS local Time Machine snapshots ###"
snap_count="$(tmutil listlocalsnapshots / 2>/dev/null | grep -c 'com.apple.TimeMachine' || true)"
echo "    local snapshots: ${snap_count}"

if [[ "${snap_count}" -gt 0 ]]; then
    echo "    These pin deleted blocks. Until they age out, everything this"
    echo "    script frees below may show as 0 GB reclaimed."
    if [[ "${THIN_SNAPSHOTS}" -eq 1 ]]; then
        warn "removing local snapshots means no local point-in-time restore"
        warn "until your next successful Time Machine backup completes."
        while read -r snap; do
            [[ -n "${snap}" ]] || continue
            # com.apple.TimeMachine.2026-09-05-204212.local -> 2026-09-05-204212
            stamp="$(echo "${snap}" | sed -E 's/^com\.apple\.TimeMachine\.(.*)\.local$/\1/')"
            run sudo tmutil deletelocalsnapshots "${stamp}"
        done < <(tmutil listlocalsnapshots / 2>/dev/null | grep 'com.apple.TimeMachine' || true)
    else
        echo "    Pass --thin-snapshots to remove them."
    fi
fi

# =============================================================================
# 1. NIX - prune old generations
# =============================================================================
echo
echo "### 1. nix generations (keeping newest ${KEEP_GENERATIONS}) ###"

# sudo -H matters: without it sudo keeps your HOME, and nix warns
#   "$HOME is not owned by you, falling back to ... '/var/root'"
# on every invocation.
# Count with a glob rather than `ls | grep`: correct for odd filenames, and
# an unmatched glob stays literal so the -e test leaves the count at 0.
sys_gens=0
for link in /nix/var/nix/profiles/system-*-link; do
    if [[ -e "${link}" ]]; then
        sys_gens=$(( sys_gens + 1 ))
    fi
done
echo "    darwin system generations: ${sys_gens}"
# /nix/var/nix/profiles/system is root-owned, which is exactly why a plain
# unprivileged `nix-collect-garbage -d` never prunes it.
if [[ "${sys_gens}" -gt "${KEEP_GENERATIONS}" ]]; then
    run sudo -H nix-env -p /nix/var/nix/profiles/system \
        --delete-generations "+${KEEP_GENERATIONS}"
else
    echo "    nothing to prune"
fi

for prof in "${HOME}/.local/state/nix/profiles/home-manager" \
            "${HOME}/.local/state/nix/profiles/profile" \
            "/nix/var/nix/profiles/per-user/${USER}/home-manager"; do
    if [[ -e "${prof}" ]]; then
        echo "    pruning user profile: $(basename "${prof}")"
        run nix-env -p "${prof}" --delete-generations "+${KEEP_GENERATIONS}"
    fi
done

if [[ -e /nix/var/nix/profiles/per-user/root/profile ]]; then
    run sudo -H nix-env -p /nix/var/nix/profiles/per-user/root/profile \
        --delete-generations "+${KEEP_GENERATIONS}"
fi

# =============================================================================
# 2. NIX - garbage collection
# =============================================================================
echo
echo "### 2. nix garbage collection ###"
echo "    Slow step - expect minutes with little output."
echo "    Only paths unreachable from a live generation are removed; anything"
echo "    deleted is rebuildable from your flake."

if [[ "${APPLY}" -eq 1 ]]; then
    gc_log="$(mktemp)"
    trap 'rm -f "${gc_log}"' EXIT
    if ! sudo -H nix-collect-garbage 2>&1 | tee "${gc_log}"; then
        warn "nix-collect-garbage exited non-zero"
    fi
    # macOS protects .app bundles: a process without App Management rights
    # cannot chmod inside one, so GC aborts on the first store path holding a
    # .app and reports "0 store paths deleted".
    if grep -q 'Operation not permitted' "${gc_log}"; then
        echo
        warn "GC hit 'Operation not permitted' on a .app bundle."
        warn "macOS blocks modifying .app bundles from processes lacking rights."
        warn "Fix: System Settings > Privacy & Security > App Management"
        warn "     (or Full Disk Access), enable your terminal, restart it,"
        warn "     then re-run. Until then nix GC frees nothing."
    fi
else
    echo "  \$ sudo -H nix-collect-garbage"
fi
echo "    free space now: $(avail) GB"

# =============================================================================
# 3. DOCKER - the VM disk image, if Docker Desktop is unused
# =============================================================================
echo
echo "### 3. docker VM disk ###"
readonly DOCKER_RAW="${HOME}/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw"

if pgrep -f "Docker Desktop" >/dev/null 2>&1 || pgrep -x "com.docker.backend" >/dev/null 2>&1; then
    warn "Docker Desktop is RUNNING - skipping. Quit it fully and re-run."
elif [[ -f "${DOCKER_RAW}" ]]; then
    # A single file, so this du is fast despite the size.
    echo "    size: $(sizeof "${DOCKER_RAW}") GB, last modified $(mtime_of "${DOCKER_RAW}")"
    warn "this destroys ALL local images, containers, and volumes."
    warn "Docker Desktop recreates an empty disk on next launch."
    warn "if a named volume holds data you care about, stop now."
    run rm -f "${DOCKER_RAW}"
    echo "    free space now: $(avail) GB"
else
    echo "    not present - nothing to do"
fi

# =============================================================================
# 4. CACHES
# =============================================================================
echo
echo "### 4. caches ###"
clear_contents "${HOME}/Library/Caches"
clear_contents "${HOME}/.cache"

if [[ "${DEV_CACHES}" -eq 1 ]]; then
    echo "    -- dev tool caches --"
    # Re-downloaded on next build: costs time, not data. Skip these on a slow
    # or metered connection; the yield is usually small next to the re-fetch.
    for c in "${HOME}/.npm/_cacache" \
             "${HOME}/Library/pnpm/store" \
             "${HOME}/.bun/install/cache" \
             "${HOME}/.gradle/caches" \
             "${HOME}/go/pkg/mod/cache/download"; do
        clear_contents "${c}"
    done
else
    echo "    dev tool caches: skipped (pass --dev-caches to include)"
fi

# =============================================================================
# report
# =============================================================================
echo
echo "=============================================="
AFTER_ROOT="$(avail)"
readonly AFTER_ROOT
if [[ "${MEASURE}" -eq 1 ]]; then
    echo "measuring nix store again (slow)..."
    echo " nix store:  ${BEFORE_NIX} -> $(sizeof /nix/store) GB"
fi
echo " free space: ${BEFORE_ROOT} GB -> ${AFTER_ROOT} GB"
awk -v b="${BEFORE_ROOT}" -v a="${AFTER_ROOT}" \
    'BEGIN{ printf " reclaimed:  %.1f GB\n", a-b }'

if [[ "${APPLY}" -eq 0 ]]; then
    echo
    echo " (dry run - numbers unchanged by design)"
elif [[ "${snap_count}" -gt 0 && "${THIN_SNAPSHOTS}" -eq 0 ]]; then
    echo
    echo " NOTE: ${snap_count} local snapshots still hold deleted blocks."
    echo " Reclaimed space may stay near zero until they age out."
fi
echo "=============================================="
