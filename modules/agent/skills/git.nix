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
  commitSkillFile = ''
    ---
    name: git-commit
    description: 'Create a new Git commit (semantic commit). Examples: "commit
      this", "create a commit", "commit staged changes", "save my work"'
    ---

    # Create a Git Commit

    ## When to Use

    - Saving a completed change to the current branch
    - After implementing a fix, feature, or refactor that is ready to record
    - When `/gs-create` is wrong because you are already on a feature branch (not creating a new stacked branch)

    ## Workflow

    ### 1. Lint first

    You MUST first run the `/lint` workflow.
    - If there are any linting issues, fix them before proceeding.
    - Only when all issues are fixed, proceed to the next step.

    ### 2. Commit

    Provide a semantic commit message (`feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`) in the format `type(scope): title`.

    - The subject line MUST be 50 characters or less.
    - The body MUST be wrapped at 72 characters.
    - The body MUST explain the **why** and **how** of the change.

    ```bash
    git commit -m "<type>: <title>

    <detailed description of why and how>"
    ```

    > [!CAUTION]
    > The AGENT MUST NEVER run `git push`. Only the USER should ever decide to run `git push`.
  '';

  amendSkillFile = ''
    ---
    name: git-amend
    description: 'Amend the current commit with a semantic commit message.
      Examples: "amend the commit", "fix the commit message", "add to last commit"'
    ---

    # Amend the Current Commit

    ## When to Use

    - Fixing a typo or improving the message of the most recent commit
    - Adding forgotten staged changes to the last commit before pushing
    - Correcting the commit type or scope

    > [!WARNING]
    > Only amend commits that have **not yet been pushed** to a shared remote.
    > Amending a published commit rewrites history and will conflict with anyone who has pulled it.

    ## Workflow

    ### 1. Lint first

    You MUST first run the `/lint` workflow.
    - If there are any linting issues, fix them before proceeding.

    ### 2. Amend

    Provide a semantic commit message (`feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`) in the format `type(scope): title`.

    - The subject line MUST be 50 characters or less.
    - The body MUST be wrapped at 72 characters.
    - The body MUST explain the **why** and **how** of the change.

    ```bash
    git commit --amend -m "<type>: <title>

    <detailed description of why and how>"
    ```

    > [!CAUTION]
    > The AGENT MUST NEVER run `git push`. Only the USER should ever decide to run `git push`.
  '';
in
{
  config = lib.mkIf enable (
    lib.mkMerge [
      (addSkill "git-commit" commitSkillFile)
      (addSkill "git-amend" amendSkillFile)
    ]
  );
}
