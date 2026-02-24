{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.soxincfg.programs.claude-code;

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
    name: address-pr-comments
    description: Address unresolved comments in a PR
    ---

    # Address Unresolved PR Comments

    This workflow guides you through fetching unresolved comments from a GitHub Pull Request and addressing them systematically.

    ## Workflow Steps

    ### 1. Fetch Unresolved Comments

    Use the helper script to fetch the unresolved comments. If no PR number is provided, it will attempt to find the PR for the current branch.

    ```bash
    # Fetch comments for the current PR
    ${get-unresolved-comments}

    # Or specify a PR number
    ${get-unresolved-comments} <PR_NUMBER>
    ```

    The script outputs a JSON array of comments. Each comment includes the `body` (feedback), `path` (file), `line`, and `threadId` (required for resolution).

    ### 2. Address Each Comment

    Iterate through the unresolved comments and perform the following for each:

    1. **Locate the issue**: Use `view_file` to examine the file and specific line mentioned in the comment.
    2. **Analyze and fix**: Understand the feedback and implement the necessary changes.
    3. **Verify**: Run relevant tests or linters (e.g., using `/test` or `/lint` workflows) to ensure the fix is correct and doesn't introduce regressions.
    4. **Commit**: Once the fix is verified, commit the change using a descriptive message.
    5. **Resolve on GitHub**: Use the `threadId` provided in the fetch step to resolve the thread on GitHub.

    ```bash
    git commit -am "fix: address PR comment regarding <context>"
    ${resolve-pr-comment} <THREAD_ID>
    ```

    ### 3. Final Review

    After addressing and resolving all comments, perform a final check of the changes and ensure the project still builds and tests pass.

    ## Internal details

    The script `${get-unresolved-comments}` uses `gh api graphql` to fetch `reviewThreads` where `isResolved` is false.
    The script `${resolve-pr-comment}` uses the `resolveReviewThread` GraphQL mutation to mark a thread as resolved.
  '';
in
{
  config = lib.mkIf cfg.enable {
    home.file.".claude/skills/address-pr-comments/SKILL.md".text = skillFile;
  };
}
