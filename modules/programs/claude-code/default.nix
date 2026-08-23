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
                description = "Whether Claude Code should refresh this marketplace on its own.";
              };
            };
          }
        );
        default = { };
        example = lib.literalExpression ''
          { kalbasit.repo = "kalbasit/marketplace"; }
        '';
        description = ''
          Plugin marketplaces to register with Claude Code.

          These are merged into `settings.json` on activation rather than written
          declaratively, because Claude Code owns that file and its plugin cache.
          A marketplace registered by hand on one machine is left alone.
        '';
      };

      plugins = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = lib.literalExpression ''[ "agent-mesh@kalbasit" ]'';
        description = ''
          Plugins to enable, as `name@marketplace`.

          Merged additively: enabling a plugin by hand on one machine is never
          undone by an activation here. Removing a plugin from this list does
          disable it, but only if this module was the one that enabled it -- what
          it added is recorded so that what you added stays yours.
        '';
      };

      agent-mesh = {
        enable = mkSubEnable "agent-mesh plugin (identity, shared memory, work queue)";

        package = lib.mkOption {
          type = lib.types.nullOr lib.types.package;
          default = null;
          description = ''
            The agent-mesh package, providing the `agent-mesh` command used by the
            sweep timer and available for interactive use. Null installs no command,
            leaving the plugin to run entirely inside Claude Code.
          '';
        };

        archive = {
          enable = lib.mkEnableOption "the periodic session-archive sweep" // {
            description = ''
              Whether to run the session-archive sweep on a timer.

              Off by default and deliberately separate from `agent-mesh.enable`:
              archiving uploads session transcripts to a store that cannot delete,
              so turning it on is a decision about permanence, not a convenience.
            '';
          };

          interval = lib.mkOption {
            type = lib.types.str;
            default = "5m";
            description = "How often the sweep runs. systemd duration syntax on Linux; converted to seconds on Darwin.";
          };
        };

        credentialsFile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          example = lib.literalExpression ''config.sops.secrets."agent-mesh/env".path'';
          description = ''
            A file of `KEY=value` lines sourced into the sweep's environment, for
            the broker password and any tracker token.

            Point this at a sops-nix secret. It is read at runtime and never copied
            into the nix store, so the secret does not become world-readable.
          '';
        };
      };
    };
  };
}
