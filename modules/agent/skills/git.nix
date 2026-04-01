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

    2. Create a new commit using `git commit`. You must provide a semantic commit message (feat, fix, docs, style, refactor, test, chore) following the format `type: title`.

    3. The commit message MUST include a description that explains the **why** and **how** of the change.

    ```bash
    git commit -m "<type>: <title>

    <detailed description of why and how>"
    ```

    Example:

    ```bash
    git commit -m "feat: add support for new storage backend

    This adds support for S3-compatible storage backends. It was needed to
    enable deployments in cloud environments without persistent local volumes.
    The implementation utilizes the AWS SDK for Go and supports...
    "
    ```

    > [!CAUTION]
    > The AGENT MUST NEVER run `git push`. Only the USER should ever decide to run `git push`.
  '';

  amendSkillFile = ''
    ---
    description: Amend the current commit with a semantic commit message
    ---

    1. Amend the current commit. You must provide a semantic commit message (feat, fix, docs, style, refactor, test, chore) following the format `type: title`.

    2. The commit message MUST include a description that explains the **why** and **how** of the change.

    ```bash
    git commit --amend -m "<type>: <title>

    <detailed description of why and how>"
    ```

    Example:
    ```bash
    git commit --amend -m "feat: improve performance of storage backend

    By using a batched read approach, we reduce the number of I/O operations.
    This implementation caches the most frequently accessed chunks in memory...
    "
    ```
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
