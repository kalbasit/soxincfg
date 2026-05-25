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
    description: Monitor a git-spice stack until all PRs are merged, handling failures automatically.
    ---

    # monitor-stack-merge

    Monitor a git-spice stack until all PRs are merged, handling failures automatically.

    ## Invocation

    Start a 2-minute recurring loop:

    ```
    /loop 2m /monitor-stack-merge
    ```

    Or invoke once manually:

    ```
    /monitor-stack-merge
    ```

    ## Each Iteration

    ### 1. Navigate to the top and list the stack

    ```bash
    gs top
    gs ls
    ```

    Identify all branches and their PR numbers (shown at the end of each line).

    ### 2. Check merge status of the bottom-most PR (closest to main)

    ```bash
    gh pr view <PR> --json state,mergedAt,statusCheckRollup \
      --jq '{state:.state, mergedAt:.mergedAt,
        failing:[.statusCheckRollup[]|select(.conclusion=="FAILURE" or .conclusion=="TIMED_OUT" or .conclusion=="ERROR")|{name:.name,url:.detailsUrl}],
        inProgress:[.statusCheckRollup[]|select(.status=="IN_PROGRESS")|.name]}'
    ```

    ### 3. Decide what to do

    #### PR merged?

    Run `yes | gs rs` to sync (this cleans up merged branches and moves the stack up).

    **Do NOT run `gs stack restack` after a clean merge.** The merge-stack-continue workflow force-pushes each PR's branch with a rebased base as it works down the stack. If you restack locally without pushing, the local SHAs diverge from what GitHub has — upper branches accumulate stale commits, causing conflicts on future restacks.

    **After `yes | gs rs`, wait for the merge-stack-continue workflow to finish** before doing anything with local branches. Check that it has completed:

    ```bash
    gh run list --workflow=merge-stack-continue.yml --limit=1 --json status,conclusion \
      --jq '.[0] | {status:.status, conclusion:.conclusion}'
    ```

    Only once it shows `completed` / `success` should you align local branches to remote. The continue workflow force-pushes **all** submitted branches in the stack (not just the next one), so fetch and reset every submitted PR branch:

    ```bash
    git fetch origin <branch1> <branch2> <branch3> ...
    git checkout <branch> && git reset --hard origin/<branch>
    # repeat for every submitted branch
    ```

    Then restack only the **unsubmitted** branches at the top with `gs stack restack`.

    **SHA mismatch warning:** If `gs rs` prints `local SHA (...) does not match remote SHA (...). Skipping...`, the merged branch wasn't cleaned up. Fix:

    ```bash
    git branch -D <merged-branch-name>
    yes | gs rs
    ```

    **If you already ran `gs stack restack` and local branches diverged from remote**, reset every submitted PR branch to its remote state (after confirming merge-stack-continue has finished):

    ```bash
    git fetch origin <branch1> <branch2> ...
    git checkout <branch> && git reset --hard origin/<branch>
    # repeat for each submitted branch
    ```

    Then restack only the unsubmitted branches at the top with `gs stack restack`.

    **Do NOT run `gs ss`** — the merge-stack-continue workflow handles submitting the next PR automatically.

    Restart the loop iteration.

    #### PR open, CI all green or in-progress?

    Nothing to do. Wait for the next tick.

    #### PR open, CI has failures?

    Diagnose the failure (see below), then act.

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
    | Rebase conflict / merge conflict in the merge-stack-continue workflow | **Rebase issue** |
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

    ### Rebase issue (merge-stack-continue stopped)

    The merge-stack-continue workflow hit a rebase conflict when trying to update a PR's base.

    1. Go to the top of the stack: `gs top`
    2. Sync: `yes | gs rs`
    3. Restack: `/gs-restack`
    4. Submit all PRs: `gs ss --update-only --force`
    5. Add the `merge-stack` label to the **top-most PR** in the stack:
       ```bash
       gh pr edit <PR> --add-label merge-stack
       ```
       The `merge-stack-start` workflow traverses the stack and starts merging from the bottom up automatically.

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
    - The `merge-stack` label drives the auto-merge workflow. If it disappears from the bottom PR for any reason, re-add it manually.
    - When all PRs are merged and the stack is empty (only `main` remains), the loop is done — stop it with CronDelete.

    ## Warning: Unexpected Conflicts During Restack

    If `gs stack restack` hits a conflict that seems surprising (the stack was clean, nothing should have diverged), **do not blindly resolve it**. Stop and investigate first:

    ```bash
    gs rba   # abort the restack
    ```

    Then diagnose: the most common cause is that local branches were restacked without waiting for the merge-stack-continue workflow to finish force-pushing all submitted branches. The local SHAs diverge from what GitHub has, causing phantom conflicts. Fix:

    1. Confirm merge-stack-continue has completed (see above).
    2. Fetch and reset every submitted PR branch to its remote state.
    3. Only then restack the unsubmitted branches at the top.

    Resolving a conflict caused by a local/remote SHA mismatch will corrupt the stack — always abort and investigate first.
  '';
in
{
  config = lib.mkIf enable (addSkill "monitor-stack-merge" skillFile);
}
