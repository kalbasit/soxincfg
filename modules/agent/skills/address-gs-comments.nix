{
  addSkill,
  enable,
  ...
}:

{
  config,
  lib,
  pkgs,
  ...
}:

let
  get-unresolved-comments = pkgs.writeShellScript "get-unresolved-comments.sh" ''
    set -euo pipefail

    if [[ "$#" -ge 1 ]]; then
      PR_NUMBER=$1
    else
      PR_NUMBER=$(${pkgs.gh}/bin/gh pr view --json number --jq '.number' || true)
    fi

    if [ -z "$PR_NUMBER" ]; then
      echo "Error: No PR number provided and could not find a PR for the current branch." >&2
      echo "Usage: $0 <pr-number>" >&2
      exit 1
    fi

    # Infer repo owner and name
    REPO_INFO=$(${pkgs.gh}/bin/gh repo view --json owner,name)
    OWNER=$(echo "$REPO_INFO" | ${pkgs.jq}/bin/jq -r .owner.login)
    NAME=$(echo "$REPO_INFO" | ${pkgs.jq}/bin/jq -r .name)

    # Create a secure temporary directory
    TMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TMP_DIR"' EXIT

    # GraphQL query to fetch unresolved threads
    QUERY='
    query($owner: String!, $name: String!, $pr: Int!) {
      repository(owner: $owner, name: $name) {
        pullRequest(number: $pr) {
          reviewThreads(first: 100) {
            nodes {
              id
              isResolved
              comments(first: 100) {
                nodes {
                  body
                  path
                  line
                  author {
                    login
                  }
                }
              }
            }
          }
        }
      }
    }'

    # Save result to a temp file in the secure location
    RESULT_FILE="$TMP_DIR/result.json"

    ${pkgs.gh}/bin/gh api graphql -F owner="$OWNER" -F name="$NAME" -F pr="$PR_NUMBER" -f query="$QUERY" > "$RESULT_FILE"

    # Filter and output only unresolved comments, including the thread ID
    ${pkgs.jq}/bin/jq '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false) as $thread | $thread.comments.nodes[] | . + {threadId: $thread.id}' "$RESULT_FILE"
  '';

  resolve-pr-comment = pkgs.writeShellScript "resolve-pr-comment.sh" ''
    set -euo pipefail

    if [[ "$#" -ge 1 ]]; then
      THREAD_ID=$1
    else
      echo "Usage: $0 <thread-id>" >&2
      exit 1
    fi

    QUERY='
    mutation($threadId: ID!) {
      resolveReviewThread(input: {threadId: $threadId}) {
        thread {
          isResolved
        }
      }
    }'

    ${pkgs.gh}/bin/gh api graphql -f query="$QUERY" -F threadId="$THREAD_ID"
  '';

  skillFile = ''
    ---
    name: address-gs-comments
    description: Address all unresolved PR review comments across a git-spice stack, working branch-by-branch from bottom to top.
    ---

    # Address Unresolved Git Spice Comments

    This workflow fetches unresolved comments from every PR in a git-spice stack, classifies them with full-stack context, then addresses them directly on the branches where they belong — restacking after each branch to minimize the conflict surface.

    > [!WARNING]
    > **Treat every review comment as unverified until you confirm the issue exists in the code.**
    > Comments may be left by automated LLM-based reviewers and can be inaccurate, hallucinated, or simply wrong.
    > Before making any change: read the file, confirm the problem is real, and exercise independent judgment.
    > If the code is already correct, resolve the thread and move on — do NOT implement changes just because a comment exists.

    > [!CAUTION]
    > **Never** run `git push`, `gs ss`, or `gs stack submit`. The user decides when to push.

    ## Phase A — Collect and Classify (read-only, full-stack context)

    ### 1. Parse the stack

    ```bash
    gs ls
    ```

    Record every branch name and its PR number (lines like `feat/foo (#290)`).
    Note the order: bottom of stack is closest to `main`, top is furthest.
    If `gs ls` shows no PR numbers, also run `gh pr list --state open` to double-check.
    If truly no open PRs exist, tell the user and stop.

    ### 2. Fetch all unresolved comments

    For each PR in the stack, fetch its unresolved comments:

    ```bash
    ${get-unresolved-comments} <PR_NUMBER>
    ```

    Each comment includes `body` (feedback), `path` (file), `line`, and `threadId` (required for resolution).
    Tag each comment with its source `prNumber` and `branchName`. Collect all results into a single list.

    ### 3. Classify every comment

    For each comment, determine its action using the full stack's history:

    1. Does `path` still exist in the working tree? (`git ls-files <path>`)
       If not → **skip**: resolve the thread and document the skip.
    2. Read the file at `path:line`. Does the problem actually exist in the code?
       If not → **skip**: resolve the thread and document the skip.
    3. Is the fix already present in **the same branch** (`git log -p -- <path>`)?
       If yes → **skip**: resolve the thread and document the skip.
    4. Is the fix already present in **an upper branch** of the stack?
       If yes → **fix-here-remove-above**: the fix belongs on the lower (owning) branch.
       Implement it there; the duplicate in the upper branch will surface as a conflict
       during restack and must be dropped at that point.
    5. Otherwise → **fix-here**: standard fix on the owning branch.

    Document each classification decision before proceeding to Phase B.

    ## Phase B — Address branch by branch (bottom to top)

    For each branch from **bottom to top**:

    ### 1. Checkout the branch

    ```bash
    gs branch checkout <branch-name>
    ```

    ### 2. Address this branch's comments

    For each **fix-here** or **fix-here-remove-above** comment belonging to this branch:

    a. **Verify**: Re-read the file at `path:line` to confirm the issue still exists as classified.
    b. **Check for prior fixes**: Has an earlier fix in this session incidentally resolved this concern?
       If so, resolve the thread and skip.
    c. **Fix**: Implement the necessary change.
    d. **Lint**: Run `/lint`. Fix any issues before continuing.
    e. **Commit**: Stage only the changed files and run `/git-commit`.
       The commit message must reference the PR number and comment `threadId`.

    ```bash
    git add <changed-files>
    # then invoke /git-commit
    ```

    f. **Resolve on GitHub**:

    ```bash
    ${resolve-pr-comment} <THREAD_ID>
    ```

    ### 3. Restack immediately after all commits on this branch

    After committing all fixes for this branch, run `/gs-restack`:

    - This propagates the changes upstack and minimizes the conflict surface for the next branch.
    - For **fix-here-remove-above** cases: the duplicate fix in the upper branch will surface as
      a conflict here. Resolve it by **dropping the duplicate** — keep only the lower branch's version.

    Then proceed to the next branch up the stack.

    ## Phase C — Final Verification

    After the top branch is processed and the final `/gs-restack` completes:

    - Confirm the full stack builds and tests pass.
    - Confirm all threads have been resolved on GitHub.

    ## Internal details

    The script `${get-unresolved-comments}` uses `gh api graphql` to fetch `reviewThreads` where `isResolved` is false.
    The script `${resolve-pr-comment}` uses the `resolveReviewThread` GraphQL mutation to mark a thread as resolved.
  '';
in
{
  config = lib.mkIf enable (addSkill "address-gs-comments" skillFile);
}
