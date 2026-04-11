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
      (addSkill "gs-create" createSkillFile)
      (addSkill "gs-restack" restackSkillFile)
    ]
  );
}
