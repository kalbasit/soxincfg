{
  config,
  lib,
  mode,
  ...
}:

let
  cfg = config.soxincfg.programs.claude-code;

  mkSubEnable =
    what:
    lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      defaultText = lib.literalExpression "config.soxincfg.programs.claude-code.enable";
      description = "Whether to install the Claude Code ${what}. Defaults to the value of `enable`.";
    };
in
{
  imports = lib.optional (mode == "home-manager") ./home.nix;

  options = {
    soxincfg.programs.claude-code = {
      enable = lib.mkEnableOption "claude-code";

      skills.enable = mkSubEnable "skills";
      rules.enable = mkSubEnable "rules";
      hooks.enable = mkSubEnable "hooks (SOPS PreToolUse guard)";

      marketplaces = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              repo = lib.mkOption {
                type = lib.types.str;
                description = "The `owner/name` GitHub repository holding the marketplace.";
              };

              autoUpdate = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = ''
                  Whether Claude Code should refresh this marketplace on its own.

                  Maps to `extraKnownMarketplaces.<name>.autoUpdate` in
                  settings.json -- the same flag `/plugin` sets. Note that the
                  activation replaces a managed marketplace's entry wholesale, so
                  this value wins over one set by hand in the UI.
                '';
              };
            };
          }
        );
        default = { };
        example = lib.literalExpression ''
          { context-mode.repo = "mksglu/context-mode"; }
        '';
        description = ''
          Plugin marketplaces to register with Claude Code.

          These are merged into `settings.json` on activation rather than written
          declaratively, because Claude Code owns that file and its plugin cache.
          A marketplace registered by hand on one machine is left alone. One
          this module registered and no longer lists is removed again.
        '';
      };

      plugins = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = lib.literalExpression ''[ "context-mode@context-mode" ]'';
        description = ''
          Plugins to enable, as `name@marketplace`.

          Merged additively: enabling a plugin by hand on one machine is never
          undone by an activation here. Removing a plugin from this list does
          uninstall it, but only if this module was the one that enabled it --
          what it added is recorded so that what you added stays yours.
        '';
      };
    };
  };
}
