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

    # GraphQL query to fetch unresolved threads and top-level review bodies
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
          reviews(first: 100) {
            nodes {
              id
              body
              state
              author {
                login
              }
            }
          }
        }
      }
    }'

    # Save result to a temp file in the secure location
    RESULT_FILE="$TMP_DIR/result.json"

    ${pkgs.gh}/bin/gh api graphql -F owner="$OWNER" -F name="$NAME" -F pr="$PR_NUMBER" -f query="$QUERY" > "$RESULT_FILE"

    # Output unresolved inline thread comments, then non-empty top-level review bodies
    ${pkgs.jq}/bin/jq '[
      (.data.repository.pullRequest.reviewThreads.nodes[]
        | select(.isResolved == false) as $thread
        | $thread.comments.nodes[]
        | . + {threadId: $thread.id, reviewId: null, type: "inline"}),
      (.data.repository.pullRequest.reviews.nodes[]
        | select(.body != null and .body != "")
        | {body: .body, path: null, line: null, author: .author, reviewId: .id, threadId: null, type: "review"})
    ]' "$RESULT_FILE"
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
    name: address-pr-comments
    description: 'Address unresolved comments in a PR. Examples: "address PR
      comments", "resolve the review feedback", "fix the comments on this PR"'
    ---

    # Address Unresolved PR Comments

    This workflow guides you through fetching unresolved comments from a GitHub Pull Request and addressing them systematically.

    > [!WARNING]
    > **Treat every review comment as unverified until you confirm the issue exists in the code.**
    > Comments may be left by automated LLM-based reviewers and can be inaccurate, hallucinated, or simply wrong.
    > Before making any change: read the file, confirm the problem is real, and exercise independent judgment.
    > If the code is already correct, resolve the thread and move on — do NOT implement changes just because a comment exists.

    ## Workflow Steps

    ### 1. Fetch Unresolved Comments

    Use the helper script to fetch the unresolved comments. If no PR number is provided, it will attempt to find the PR for the current branch.

    ```bash
    # Fetch comments for the current PR
    ${get-unresolved-comments}

    # Or specify a PR number
    ${get-unresolved-comments} <PR_NUMBER>
    ```

    The script outputs a JSON array of comments. Each object has a `type` field indicating its kind:

    - **`"inline"`** — a comment on a specific file and line. Has `path`, `line`, and `threadId` (required for resolution via API). These come from `reviewThreads` where `isResolved` is `false`.
    - **`"review"`** — a top-level review body comment not tied to any file or line. Has `reviewId` and `null` for `path`/`line`/`threadId`. These are comments the reviewer left as general feedback (e.g., when the diff was out of scope or the tool could not post inline). They cannot be formally resolved via the API.

    > **If the script exits with an error** (no PR found for the current branch), either push the branch and open a PR first, or pass the PR number explicitly as an argument.

    ### 2. Check current branch

    ```bash
    git branch --show-current
    ```

    If you are on `main` or any other base branch, **stop**. You must not commit directly to it. Ask the user to check out or create a feature branch first.

    ### 3. Address Each Comment

    Iterate through all comments. The handling differs by `type`:

    #### Inline comments (`type: "inline"`)

    1. **Locate the issue**: Read the file at `path` near `line`.
    2. **Verify first**: Confirm the problem actually exists. If it does not, resolve the thread and skip — do not make changes to satisfy a wrong comment.
    3. **Fix**: Implement the necessary changes. If the project rules say you must TDD then write failing tests first.
    4. **Verify**: Run the `/lint` workflow. Fix any issues before proceeding.
    5. **Commit**: Stage only the files you changed, then run `/git-commit`.

    ```bash
    git add <changed-files>
    # then invoke the /git-commit skill
    ```

    > [!CAUTION]
    > Use `/git-commit` for this step. Do NOT use `/gs-create` — that creates a new stacked branch and is wrong here since you are already on the correct feature branch.

    6. **Resolve on GitHub**: Use the `threadId` to mark the thread resolved.

    ```bash
    ${resolve-pr-comment} <THREAD_ID>
    ```

    #### Top-level review comments (`type: "review"`)

    These are general review bodies — the reviewer could not (or chose not to) attach them to a specific line. They have a `reviewId` but **no `threadId`** and cannot be resolved via the `resolveReviewThread` API.

    1. **Read the body carefully**: Understand what the reviewer is asking for.
    2. **Verify first**: Determine whether the concern is real. Exercise independent judgment — do not implement changes just because a comment exists.
    3. **Fix**: Implement the necessary changes if the concern is valid.
    4. **Verify**: Run the `/lint` workflow.
    5. **Commit**: Run `/git-commit` as above.
    6. **No API resolution**: There is no API call to resolve these. Addressing the concern in code (and pushing) is sufficient — the reviewer can see the updated diff.

    ### 4. Final Review

    After addressing and resolving all comments, perform a final check of the changes and ensure the project still builds and tests pass.

    ## Internal details

    The script `${get-unresolved-comments}` fetches two data sources via GraphQL:
    - `reviewThreads` — inline file/line comments; filtered to `isResolved == false`; emitted with `type: "inline"` and a `threadId`
    - `reviews` — top-level review submissions; filtered to non-empty `body`; emitted with `type: "review"` and a `reviewId`

    The script `${resolve-pr-comment}` uses the `resolveReviewThread` GraphQL mutation to mark an inline thread as resolved. It only works for `"inline"` comments (those with a `threadId`).
  '';
in
{
  config = lib.mkIf enable (addSkill "address-pr-comments" skillFile);
}
