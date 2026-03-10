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
    description: Lint and format code
    ---

    **CRITICAL**: If the project has its own lint skill, refer to it instead. If not, here's generic guidelines for linting:

    1. If the project has a flake.nix then run the Nix formatter:

    ```bash
    nix fmt
    ```

    2. If this is a Go project, then run golangci-lint as well:

    ```bash
    golangci-lint run --fix
    ```

    3. (If SQL files modified) Lint SQL files:

    ```bash
    sqlfluff lint db/query.*.sql db/migrations/
    ```
  '';
in
{
  config = lib.mkIf enable (addSkill "lint" skillFile);
}
