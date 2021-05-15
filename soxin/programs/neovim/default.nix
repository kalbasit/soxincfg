{ mode, config, pkgs, lib, ... }:

with lib;
let
  cfg = config.soxin.programs.neovim;
in
{
  options = {
    soxin.programs.neovim = {
      enable = mkEnableOption "Whether to enable NeoVim.";

      extraRC = mkOption {
        default = "";
        type = types.lines;
        description = "Extra NeoVim init configuration.";
      };

      extraKnownPlugins = mkOption {
        default = { };
        description = "Extra NeoVim known plugins.";
      };

      extraPluginDictionaries = mkOption {
        type = with types; listOf attrs;
        default = [ ];
        description = "Extra NeoVim plugin dictionaries.";
      };

      neovimConfig = mkOption {
        type = types.attrs;
        internal = true;
        readOnly = true;
        default = (import ./config.nix {
        inherit (cfg) extraRC extraKnownPlugins extraPluginDictionaries;
        inherit config pkgs;
      });
        description = "NeoVim configuration passed to pkgs.wrapNeovim.";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      environment.variables.EDITOR = "nvim";

      environment.systemPackages = [
        (pkgs.wrapNeovim pkgs.neovim.unwrapped cfg.neovimConfig)
      ];
    })

    (optionalAttrs (mode == "home-manager") {
      programs.neovim = recursiveUpdate cfg.neovimConfig {
        enable = true;
      };
    })
  ]);
}
