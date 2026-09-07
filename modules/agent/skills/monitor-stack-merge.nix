{
  addSkill,
  enable,
  ...
}:

{
  config,
  lib,
  ...
}:

let
  skillFile = ''
    ---
    name: monitor-stack-merge
    description: 'Monitor a stack of PRs until all are merged, handling
      failures automatically. Uses GitHub native stacks for merging.
      Examples: "monitor the stack", "watch PRs until merged", "keep an eye
      on the merge queue"'
    ---

    # monitor-stack-merge

    Monitor a stack of pull requests until all are merged, handling failures automatically.

    Branches are managed locally with git-spice (`gs`). Merging is done with
    **GitHub native stacks** (`gh stack`), which replaced the old `merge-stack`
    label and its `merge-stack-start` / `merge-stack-continue` workflows.

    ## Invocation

    Start a 2-minute recurring loop:

    ```
    /loop 2m /monitor-stack-merge
    ```

    Or invoke once manually:

    ```
    /monitor-stack-merge
    ```

    ## Prerequisites

    The stack must exist **on GitHub**, not just locally. git-spice does not yet
    create native stacks (abhinav/git-spice#1388; the `submit`-side PR #1400 is
    still an open draft), so after `gs ss` you must adopt the PRs into a native
    stack once:

    ```bash
    gh stack link <bottom-PR> <next-PR> ... <top-PR>
    ```

    `gh stack link` adopts existing PRs — including renovate/dependabot branches —
    and rewrites their bases into a linear chain. Auto-merge must be **off** on
    those PRs first, or `link` refuses:

    ```bash
    gh pr merge --disable-auto <PR>
    ```

    Confirm the stack exists before monitoring:

    ```bash
    gh stack view --short
    gh api repos/{owner}/{repo}/stacks --jq '.[] | "stack \(.number) open=\(.open) prs=\([.pull_requests[].number])"'
    ```

    ## Each Iteration

    ### 1. List the stack

    ```bash
    gs ls
    gh stack view --short
    ```

    `gh stack view` status icons: `✓` merged, `◎` queued, `○` open, `⚠` needs rebase.

    ### 2. Check the lowest unmerged PR

    ```bash
    gh pr view <PR> --json state,mergedAt,statusCheckRollup \
      --jq '{state:.state, mergedAt:.mergedAt,
        failing:[.statusCheckRollup[]|select(.conclusion=="FAILURE" or .conclusion=="TIMED_OUT" or .conclusion=="ERROR")|{name:.name,url:.detailsUrl}],
        inProgress:[.statusCheckRollup[]|select(.status=="IN_PROGRESS")|.name]}'
    ```

    The lowest unmerged PR is the one whose `stack.base.ref` equals its own
    `base.ref` — it targets the stack base directly.

    ### 3. Decide what to do

    #### Whole stack green and approved?

    Merge it atomically:

    ```bash
    gh stack merge --yes
    ```

    This is **all-or-nothing**: every PR up to and including your selection lands
    on the base branch in one operation, bottom-up. If any one PR cannot merge,
    none do. Pass a PR number to merge only up to that point:

    ```bash
    gh stack merge <PR> --yes
    ```

    Before it will merge, GitHub requires that every PR below is approved with
    passing checks, that the stack is linear, and that branch protection for the
    stack base is satisfied. Bypassing merge requirements is not supported for
    stacks. If the base branch uses a merge queue, the stack is added to the queue.

    #### Bottom PR merged, stack partially landed?

    GitHub rebases the next unmerged PR to target the stack base directly —
    server-side, with no local action. Sync local branches to match:

    ```bash
    yes | gs rs
    ```

    **Do not force-push branches to "fix" the stack after a merge.** GitHub has
    already rewritten the bases; force-pushing invalidates every branch above.

    **SHA mismatch:** if `gs rs` prints `local SHA (...) does not match remote SHA
    (...). Skipping...`, the merged branch was not cleaned up:

    ```bash
    git branch -D <merged-branch-name>
    yes | gs rs
    ```

    #### PR open, CI all green or in-progress?

    Nothing to do. Wait for the next tick.

    #### PR open, CI has failures?

    Diagnose the failure (see below), then act.

    ---

    ## CI runs on every PR in the stack

    Workflows trigger **as if each PR targets the stack base**, so a workflow
    pinned to `branches: [main]` runs for every PR in the stack, not just the
    bottom one. A stacked PR showing no CI at all is almost always the
    stack-formation timing hole: the PR joined the stack *after* its last push, so
    no `pull_request` event has fired since. Push any commit to trigger one.

    ---

    ## Diagnosing Failures

    ### Step 1 — Get the run details

    ```bash
    gh run view <run-id>
    ```

    Look at the annotations and failed job names.

    ### Step 2 — Classify the failure

    | Symptom | Classification |
    |---------|---------------|
    | "Bad credentials", transient network error, runner setup error | **Intermittent** |
    | `⚠ Needs rebase`, or a "Rebase stack" button in the merge box | **Non-linear stack** |
    | Test failure, lint error, build error in application code | **Legitimate** |

    ---

    ## Mitigation Plans

    ### Intermittent failure

    Re-run **only the failed job** (not the whole run). This avoids re-triggering expensive long-running jobs (e.g. multi-arch Docker builds) that are already passing or running.

    ```bash
    gh run rerun <run-id> --job <job-id>
    ```

    **Important:** You cannot re-run a job while its parent run is still `in_progress`. If the run has a cancelled job but is still in progress (other jobs still running), don't wait — cancel the whole run and rerun it immediately so all jobs restart in parallel:

    ```bash
    gh run cancel <run-id>
    gh run rerun <run-id>
    ```

    **Warning:** Do NOT force-push a branch to trigger a new CI run — force-pushing invalidates the base of all branches above it in the stack. Instead, cancel and rerun the existing workflow run as shown above.

    **Check job dependencies before deciding:** Read the CI workflow file (e.g. `.github/workflows/ci.yml`) to understand which jobs depend on the failed one. Re-running a job automatically cascades to all jobs that `needs:` it — so re-running an upstream job (like `filter`) is enough; you do not need to separately re-run its dependents.

    **Exception — re-run the whole run instead of a single job when:**
    - The failed job is the final gate job (e.g. `ci` with `if: always()`)
    - The run has had prior cancellations or partial reruns — stale `"result": "cancelled"` from earlier attempts will poison the `ci` gate even after individual jobs pass

    ```bash
    gh run rerun <run-id>
    ```

    ### Non-linear stack

    GitHub only merges a linear stack (A -> B -> C). A divergence (A -> B and
    A -> D) blocks the merge and surfaces a "Rebase stack" button.

    ```bash
    gh stack rebase
    ```

    This does a cascading rebase across the stack. Then re-submit through
    git-spice so local tracking stays consistent:

    ```bash
    gs ss --update-only --force
    ```

    If the local and remote stacks have diverged in *composition* (not just
    commits), reconcile with GitHub as the source of truth:

    ```bash
    gh stack sync
    ```

    > [!CAUTION]
    > `gh stack sync` does its own cascade-rebase and atomic force-push
    > (`--force-with-lease --atomic`), which can fight git-spice's tracking.
    > Prefer `gs rs` / `/gs-restack` for routine local work and reach for
    > `gh stack sync` only to repair a genuine local/remote composition
    > divergence. Never run both back to back without re-reading the stack.

    ### Legitimate failure

    A real bug introduced by one of the PRs in the stack.

    1. Go to the top of the stack: `gs top`
    2. Sync: `yes | gs rs`
    3. Restack: `/gs-restack`
    4. Check out the branch for the failing PR: `gs bco <branch>`
    5. Reproduce and fix the issue.
    6. Commit the fix: `/git-commit`
    7. Restack to propagate the fix upstack: `/gs-restack`
    8. Submit all PRs: `gs ss --update-only --force`

    ---

    ## Notes

    - Branches without PR numbers (unsubmitted) are ignored — only branches with `(#NNN)` need monitoring.
    - Merging is driven by `gh stack merge`, not by a label. There is no
      `merge-stack` label and no `merge-stack-start` / `merge-stack-continue`
      workflow — those were removed once native stacks landed.
    - Stacks must be linear. GitHub rejects `A -> B` and `A -> D` coexisting.
    - When all PRs are merged and the stack is empty (only `main` remains), the loop is done — stop it with CronDelete.

    ## Warning: Unexpected Conflicts During Restack

    If `gs stack restack` hits a conflict that seems surprising (the stack was clean, nothing should have diverged), **do not blindly resolve it**. Stop and investigate first:

    ```bash
    gs rba   # abort the restack
    ```

    Then diagnose. The most common cause is that GitHub rewrote branch bases
    server-side — during an atomic stack merge, or a cascading rebase triggered
    from the pull request — and the local branches still hold the pre-rewrite
    SHAs. Fix:

    1. Confirm no stack merge or rebase is still in flight: `gh stack view --short`.
    2. Fetch and reset every submitted PR branch to its remote state.
    3. Only then restack the unsubmitted branches at the top.

    Resolving a conflict caused by a local/remote SHA mismatch will corrupt the stack — always abort and investigate first.
  '';
in
{
  config = lib.mkIf enable (addSkill "monitor-stack-merge" skillFile);
}
