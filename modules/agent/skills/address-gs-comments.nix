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
    description: Address all unresolved PR review comments across an entire git-spice stack in a single consolidation branch.
    ---

    # Address Unresolved Git Spice Comments

    This workflow guides you through fetching unresolved comments from all GitHub Pull Requests for a given git-spice stack and addressing them systematically in a single branch at the top of the stack.

    > [!WARNING]
    > **Treat every review comment as unverified until you confirm the issue exists in the code.**
    > Comments may be left by automated LLM-based reviewers and can be inaccurate, hallucinated, or simply wrong.
    > Before making any change: read the file, confirm the problem is real, and exercise independent judgment.
    > If the code is already correct, resolve the thread and move on — do NOT implement changes just because a comment exists.

    ## Workflow Steps

    ### 1. Parse the stack and collect PR numbers

    ```sh
    gs ls
    ```

    Extract every PR number visible in the output (lines like `#290`, `#294`, etc.).
    If `gs ls` shows no PR numbers, also run `gh pr list --state open` to double-check.
    If truly no open PRs exist, tell the user and stop.

    ### 2. Create the consolidation branch

    **Branch naming rule** (pick the first that applies):

    1. If PR numbers are contiguous (e.g. 290–295): `gs-comments-290-295`
    2. If non-contiguous (e.g. 290, 293, 295): `gs-comments-290-293-295`
    3. Fallback (parse failure): `gs-comments-<YYYYMMDDHHmm>`

    **Create the branch** (from the top of the stack, no initial commit):

    ```sh
    gs top && gs branch create --no-commit <branch-name>
    ```

    > **Never** run `git push`, `gs ss`, or `gs stack submit`. The user decides when to push.

    ### 3. Fetch Unresolved Comments from every PR.

    For each PR number in ascending order: Use the helper script to fetch the unresolved comments.

    ```bash
    # Fetch comments for a given PR number.
    ${get-unresolved-comments} <PR_NUMBER>
    ```

    The script outputs a JSON array of comments. Each comment includes the `body` (feedback), `path` (file), `line`, and `threadId` (required for resolution).

    Tag each returned comment object with its source `prNumber`. Collect all results
    into a single ordered list.

    ### 4. Assess relevance

    For each comment:

    1. Does `path` still exist in the working tree? (`git ls-files <path>`)
    2. Is the concern already addressed by a later commit on the stack?
       (`git log --all -p -- <path>` — look for the fix the reviewer requested)

    Skip comments that no longer apply; document each skip briefly.

    ### 5. Address relevant comments (ascending PR order)

    Iterate through the unresolved comments and perform the following for each:

    1. **Locate the issue**: Use `view_file` to examine the file and specific line mentioned in the comment.
    2. **Verify first**: Read the file at the given path and line. Confirm the problem actually exists in the code. If it does not, resolve the thread and skip to the next comment — do not make changes to satisfy a comment that is wrong.
    3. **Check for prior fixes**: Before implementing, check whether an earlier fix in this same session already addresses this concern — a change for one comment may have incidentally resolved another.
    4. **Fix**: Implement the necessary changes to address the feedback. If the project rules say you must TDD then write failing tests for the comment first before fixing it.
    5. **Verify**: Run the `/lint` workflow. Fix any issues before proceeding.
    6. **Commit**: Stage only the files you changed, then run `/git-commit`. The commit message must reference the PR number and comment `threadId`.

    ```bash
    git add <changed-files>
    # then invoke the /git-commit skill
    ```

    7. **Resolve on GitHub**: Use the `threadId` provided in the fetch step to resolve the thread on GitHub.

    ```bash
    ${resolve-pr-comment} <THREAD_ID>
    ```

    ### 6. Final Verification

    After addressing and resolving all comments, perform a final check of the changes and ensure the project still builds and tests pass.

    ## Internal details

    The script `${get-unresolved-comments}` uses `gh api graphql` to fetch `reviewThreads` where `isResolved` is false.
    The script `${resolve-pr-comment}` uses the `resolveReviewThread` GraphQL mutation to mark a thread as resolved.
  '';
in
{
  config = lib.mkIf enable (addSkill "address-gs-comments" skillFile);
}
