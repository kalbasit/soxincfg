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
    name: gs-submit
    description: 'Submit a PR via git-spice using gs branch submit with a custom
      title and body. Examples: "file a PR", "submit this branch",
      "open a pull request", "open PRs for the stack"'
    ---

    # Submit a PR with git-spice

    ## When to Use

    - Filing a new PR for the current branch
    - Filing new PRs for each branch in a stack (bottom to top)
    - Pushing an update to an existing PR's branch (base, draft status, labels, reviewers)

    > **Note:** `--title` and `--body` only apply when **creating** a new PR.
    > For existing PRs, git-spice silently ignores them — there is no way to update
    > a PR's title or body via `gs branch submit` after creation.

    ## Workflow — Single Branch

    1. Review commits: `git log main..HEAD --oneline`
    2. Compose a semantic title and body, then submit:

    ```bash
    gs branch submit \
      --title "<type(scope): description>" \
      --body "$(cat <<'EOF'
    ## Summary

    - what changed and why

    ## Test plan

    - [ ] task fmt / lint / test pass
    - [ ] smoke-test the feature
    EOF
    )"
    ```

    ## Workflow — Stack (Multiple Branches)

    1. Run `gs ls` to see the full stack and identify which branches already have PRs.
       Branches with an existing PR show `(#NNNN)`; new branches show nothing.
       The current branch is marked with `◀` at the end. Stack is listed top-to-bottom:

       ```
           ┏━■ user/you/top-branch (#1042) (needs push) ◀
         ┏━┻□ user/you/mid-branch (#1041) (needs push)
       ┏━┻□ user/you/bottom-branch
       main
       ```

    2. Starting from the **bottommost** branch, for each branch:

       | Branch state    | Command                                                       |
       | --------------- | ------------------------------------------------------------- |
       | No existing PR  | `gs branch submit --branch <name> --title "..." --body "..."` |
       | Has existing PR | `gs branch submit --branch <name>` (omit title/body)          |

       Example for a 3-branch stack where the bottom two need new PRs:

       ```bash
       # bottom — new PR (no #NNNN in gs ls)
       gs branch submit --branch user/you/bottom-branch \
         --title "fix(foo): correct bar calculation" \
         --body "$(cat <<'EOF'
       ## Summary

       - Fixed off-by-one in bar calculation
       EOF
       )"

       # mid — new PR (no #NNNN in gs ls)
       gs branch submit --branch user/you/mid-branch \
         --title "feat(foo): expose bar via API" \
         --body "$(cat <<'EOF'
       ## Summary

       - Added GET /bar endpoint
       EOF
       )"

       # top — existing PR (#1042 shown in gs ls), just push
       gs branch submit --branch user/you/top-branch
       ```

    ## Optional Flags

    | Flag                      | Purpose                                                           |
    | ------------------------- | ----------------------------------------------------------------- |
    | `--draft` / `--no-draft`  | Open as draft PR (or not)                                         |
    | `--label foo`             | Add label (repeatable)                                            |
    | `--reviewer handle`       | Request a reviewer (repeatable)                                   |
    | `--assign handle`         | Assign to a user (repeatable)                                     |
    | `--fill`                  | Auto-fill title/body from commit messages (skips manual drafting) |
    | `--no-publish`            | Push branch without creating a PR                                 |
    | `--update-only`           | Only update branches that already have a PR                       |
    | `--dry-run`               | Show what would be submitted without submitting                   |
    | `--nav-comment`           | Control navigation comment (`true`/`false`/`multiple`)            |
    | `--web` / `--no-web`      | Open PR in browser after submit                                   |

    > [!CAUTION]
    > **NEVER** run `gs ss` or `gs stack submit`. Only the USER decides to submit a
    > full stack at once. Always use `gs branch submit --branch <name>` per branch.
    >
    > `--title`/`--body` are silently ignored for branches that already have a PR.
    > git-spice provides no mechanism to update a PR's title or body after creation.
  '';
in
{
  config = lib.mkIf enable (addSkill "gs-submit" skillFile);
}
