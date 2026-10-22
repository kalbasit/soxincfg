{ nixpkgs, ... }:

let
  inherit (nixpkgs) lib;
  inherit (lib) mkOption types;
in
rec {
  toolsModule = types.submodule (
    { name, ... }:
    {
      options = {
        vscode = mkOption {
          type = vscodeModule;
          default = { };
        };
      };
    }
  );

  vscodeModule =
    with types;
    submodule {
      options = {
        extensions = mkOption {
          type = types.listOf types.package;
          default = [ ];
          example = literalExample "[ pkgs.vscode-extensions.bbenoist.Nix ]";
          description = ''
            The extensions Visual Studio Code should be started with.
            These will override but not delete manually installed ones.
          '';
        };
      };
    };

}
