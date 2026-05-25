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
  skillFile = ''
    ---
    name: lint
    description: 'Lint and format code. Examples: "lint this", "format the code",
      "fix linting errors", "run the formatter"'
    ---

    # Lint and Format Code

    ## When to Use

    - Before every commit (required by `/git-commit` and `/gs-create`)
    - After making code changes to catch style or correctness issues early
    - When the CI reports formatting or lint failures

    > [!WARNING]
    > **CRITICAL**: If the project has its own `/lint` skill defined in a project-level
    > `CLAUDE.md` or `.claude/` config, use that instead. The steps below are generic fallbacks.

    ## Workflow

    Run the applicable steps for this project's tech stack:

    | Condition | Command |
    | --------- | ------- |
    | Project has `flake.nix` | `nix fmt` |
    | Go project | `golangci-lint run --fix` |
    | SQL files modified | `sqlfluff lint db/query.*.sql db/migrations/` |

    ### Step 1 — Nix formatter (if `flake.nix` present)

    ```bash
    nix fmt
    ```

    ### Step 2 — Go linter (if Go project)

    ```bash
    golangci-lint run --fix
    ```

    ### Step 3 — SQL linter (if SQL files modified)

    ```bash
    sqlfluff lint db/query.*.sql db/migrations/
    ```
  '';
in
{
  config = lib.mkIf enable (addSkill "lint" skillFile);
}
