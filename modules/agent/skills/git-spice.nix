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
  createSkillFile = ''
    ---
    description: Create a new Git Spice stack (semantic commit)
    ---

    1. You MUST first run the `/lint` workflow.
       - If there are any linting issues, you must fix them before proceeding.
       - Only when all issues are fixed, proceed to the next step.

    2. Create a new stack using `gs branch create`. You must provide a semantic commit message (feat, fix, docs, style, refactor, test, chore) following the format `type: title`.

    3. The commit message MUST include a description that explains the **why** and **how** of the change.

    ```bash
    gs branch create -am "<type>: <title>

    <detailed description of why and how>"
    ```

    Example:

    ```bash
    gs branch create -am "feat: add support for new storage backend

    This adds support for S3-compatible storage backends. It was needed to
    enable deployments in cloud environments without persistent local volumes.
    The implementation utilizes the AWS SDK for Go and supports...
    "
    ```

    > [!CAUTION]
    > The AGENT MUST NEVER run `gs ss`, or its long version `gs stack submit`. Only the USER should ever decide to run `gs ss`.
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

        - **CRITICAL**: Once all files are resolved, use Git's continue as usual with `git rebase --continue`

    3. Repeat step 2 as necessary until the restack is complete.
  '';
in
{
  config = lib.mkIf enable (
    lib.mkMerge [
      (addSkill "gs-create" createSkillFile)
      (addSkill "gs-amend" amendSkillFile)
      (addSkill "gs-restack" restackSkillFile)
    ]
  );
}
