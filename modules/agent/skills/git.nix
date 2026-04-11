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
    description: Create a new Git commit (semantic commit)
    ---

    1. You MUST first run the `/lint` workflow.
      - If there are any linting issues, you must fix them before proceeding.
      - Only when all issues are fixed, proceed to the next step.

    2. Create a new commit using `git commit`.
      - You must provide a semantic commit message (feat, fix, docs, style, refactor, test, chore) following the format `type: title`.
      - The commit message MUST include a description that explains the **why** and **how** of the change.
      - The commit message MUST follow the 50/72 rule. The subject line MUST be 50 characters or less, and the body MUST be wrapped at 72 characters.

    ```bash
    git commit -m "<type>: <title>

    <detailed description of why and how>"
    ```

    > [!CAUTION]
    > The AGENT MUST NEVER run `git push`. Only the USER should ever decide to run `git push`.
  '';

  amendSkillFile = ''
    ---
    description: Amend the current commit with a semantic commit message
    ---

    1. Amend the current commit. You must provide a semantic commit message (feat, fix, docs, style, refactor, test, chore) following the format `type: title`.

    2. Create a new commit using `git commit`.
      - You must provide a semantic commit message (feat, fix, docs, style, refactor, test, chore) following the format `type: title`.
      - The commit message MUST include a description that explains the **why** and **how** of the change.
      - The commit message MUST follow the 50/72 rule. The subject line MUST be 50 characters or less, and the body MUST be wrapped at 72 characters.

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
