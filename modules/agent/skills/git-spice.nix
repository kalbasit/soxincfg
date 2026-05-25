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
  referenceSkillFile = ''
    ---
    name: git-spice
    description: git-spice (gs) command reference for stacked branches and PRs. Use whenever you need to understand or execute any gs command.
    ---

    # Git Spice (gs) Reference

    git-spice is a CLI tool for creating, navigating, and submitting stacked Git branches as pull requests.

    ## Core Concepts

    **Stacked branches**: A series of branches where each is based on the previous, forming a chain rooted at trunk (`main`/`master`).

    ```
        ┌── feat3 (#3)    ← top of stack
      ┌─┴ feat2 (#2)
    ┌─┴ feat1 (#1)        ← bottom of stack
    main                  ← trunk
    ```

    **Upstack**: branches above the current one. **Downstack**: branches below.

    ## Command Reference

    | Command | Shorthand | Description |
    |---------|-----------|-------------|
    | `gs branch create` | `gs bc` | Create a new branch on the stack |
    | `gs branch checkout` | `gs bco` | Switch to another tracked branch |
    | `gs branch submit` | `gs bs` | Submit current branch as PR |
    | `gs branch restack` | `gs br` | Rebase current branch onto its base |
    | `gs branch delete` | `gs bd` | Delete a branch |
    | `gs branch onto` | `gs bon` | Move branch onto a different base |
    | `gs branch edit` | `gs be` | Interactive rebase for current branch |
    | `gs branch rename` | `gs brn` | Rename a branch |
    | `gs branch diff` | `gs bdi` | Diff between branch and its base |
    | `gs branch track` | `gs btr` | Track an existing branch |
    | `gs branch untrack` | `gs buntr` | Untrack a branch |
    | `gs branch fold` | `gs bfo` | Merge branch into its base |
    | `gs branch squash` | `gs bsq` | Squash branch into one commit |
    | `gs branch split` | `gs bsp` | Split a branch on commits |
    | `gs stack submit` | `gs ss` | Submit entire stack as PRs |
    | `gs stack restack` | `gs sr` | Rebase all branches in the stack |
    | `gs stack edit` | `gs se` | Edit order of branches in stack |
    | `gs stack delete` | `gs sd` | Delete all branches in the stack |
    | `gs upstack submit` | `gs uss` | Submit current branch and all above |
    | `gs upstack restack` | `gs usr` | Restack current branch and all above |
    | `gs upstack onto` | `gs uon` | Move branch and upstack onto another |
    | `gs upstack delete` | `gs usd` | Delete current branch and all above |
    | `gs downstack submit` | `gs dss` | Submit current branch and all below |
    | `gs downstack edit` | `gs dse` | Edit order of branches below |
    | `gs downstack track` | `gs dstr` | Track all untracked branches below |
    | `gs repo sync` | `gs rs` | Pull latest, delete merged branches |
    | `gs repo init` | `gs ri` | Initialize git-spice in the repo |
    | `gs repo restack` | `gs rr` | Restack all tracked branches |
    | `gs commit create` | `gs cc` | Create a new commit |
    | `gs commit amend` | `gs ca` | Amend the current commit |
    | `gs commit split` | `gs csp` | Split the current commit |
    | `gs commit fixup` | `gs cf` | Fixup a commit below the current one |
    | `gs commit pick` | `gs cp` | Cherry-pick a commit |
    | `gs rebase continue` | `gs rbc` | Continue an interrupted rebase |
    | `gs rebase abort` | `gs rba` | Abort an interrupted rebase |
    | `gs log short` | `gs ls` | List tracked branches with PR numbers |
    | `gs log long` | `gs ll` | List branches with commits |
    | `gs up` | `gs u` | Move up one branch |
    | `gs down` | `gs d` | Move down one branch |
    | `gs top` | `gs U` | Jump to top of stack |
    | `gs bottom` | `gs D` | Jump to bottom of stack |
    | `gs trunk` | — | Return to trunk (main/master) |

    ## Key Workflows

    ### View the stack

    ```bash
    gs ls    # list branches and PR numbers
    gs ll    # list with commits
    ```

    ### Create a branch on the stack

    ```bash
    gs bc <branch-name> -m "<commit message>"
    # or with all staged changes:
    gs bc <branch-name> -am "<commit message>"
    ```

    ### Navigate the stack

    ```bash
    gs up / gs down        # move one step up or down
    gs top / gs bottom     # jump to top or bottom
    gs trunk               # return to main/master
    gs bco <branch-name>   # jump directly to a named branch
    ```

    ### Sync and restack after upstream changes

    ```bash
    yes | gs rs    # sync with remote (pull trunk, clean merged branches)
    gs sr          # restack all branches onto updated trunk
    ```

    ### Submit PRs

    ```bash
    gs bs          # submit current branch only
    gs ss          # submit entire stack (USER ONLY — agent must not run this)
    gs uss         # submit current + all above
    gs dss         # submit current + all below
    ```

    ### Handle rebase conflicts

    ```bash
    # After resolving conflict markers in files:
    git add <resolved-files>
    gs rbc    # continue the rebase

    # Or abort entirely:
    gs rba
    ```

    ## Constraints

    > [!CAUTION]
    > The agent must **NEVER** run `git push`, `gs ss`, or `gs stack submit`.
    > Only the user decides when to push branches or submit the stack for review.
  '';

  createSkillFile = ''
    ---
    description: Create a new Git Spice stack (semantic commit)
    ---

    1. You MUST first run the `/lint` workflow.
       - If there are any linting issues, you must fix them before proceeding.
       - Only when all issues are fixed, proceed to the next step.

    2. Create a new stack using `gs branch create`.
      - You must provide a semantic commit message (feat, fix, docs, style, refactor, test, chore) following the format `type: title`.
      - The commit message MUST include a description that explains the **why** and **how** of the change.
      - The commit message MUST follow the 50/72 rule. The subject line MUST be 50 characters or less, and the body MUST be wrapped at 72 characters.

    ```bash
    gs branch create -am "<type>: <title>

    <detailed description of why and how>"
    ```

    > [!CAUTION]
    > The AGENT MUST NEVER run `git push`, `gs ss`, or its long version `gs stack submit`. Only the USER should ever decide to run `gs ss`.
  '';

  restackSkillFile = ''
    ---
    description: Restack the current Git Spice stack and resolve conflicts
    ---

    1. Start the restacking process:

    ```bash
    gs stack restack
    ```

    2. If conflicts are found:
        - Review the output to identify which commit is being rebased and the files involved.
        - Examine the conflict markers in the affected files.
        - **Generated files**: If the file is generated, then do not resolve it manually. Instead, restore it from `HEAD` and regenerate it correctly.
        - **Other files**: Resolve the conflicts by choosing the correct changes based on the context of the PR stack.
        - Stage the resolved files:

        ```bash
        git add <resolved-files>
        ```

    3. **CRITICAL**: Once all files are resolved, use `gs rebase continue` to continue the restacking process.

    4. Repeat step 2-3 as necessary until the restack is complete.
  '';
in
{
  config = lib.mkIf enable (
    lib.mkMerge [
      (addSkill "git-spice" referenceSkillFile)
      (addSkill "gs-create" createSkillFile)
      (addSkill "gs-restack" restackSkillFile)
    ]
  );
}
