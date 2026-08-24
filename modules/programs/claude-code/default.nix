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
  imports =
    lib.optional (mode == "home-manager") ./home.nix
    # The broker credential is declared per platform, because sops is wired per
    # platform: soxin adds sops-nix's NixOS module to NixOS hosts and nothing to
    # nix-darwin, so there is no single declaration that serves both.
    ++ lib.optional (mode == "NixOS") ./nixos.nix;

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

        broker = {
          host = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "192.168.54.3";
            description = ''
              The MQTT broker agents use for push delivery and live presence.

              Null leaves messaging on the shared store, which is slower but
              always available -- the mesh is designed to work either way, so
              this is a performance choice rather than a required one.
            '';
          };

          port = lib.mkOption {
            type = lib.types.port;
            default = 1883;
            description = "Broker port.";
          };

          username = lib.mkOption {
            type = lib.types.str;
            default = "agent-mesh";
            description = ''
              The broker account agents authenticate as. Scoped by the broker's
              ACL to the agent topic tree, so it cannot read or write what the
              rest of the house uses.
            '';
          };

          passwordFile = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            # Null means "the path this module's own sops secret decrypts to",
            # which each mode computes for itself -- the home directory is not
            # reachable from the same place in a NixOS and a home-manager
            # evaluation, and this option is declared once for both.
            default = null;
            defaultText = lib.literalExpression ''"''${home}/.config/agent-mesh/mqtt-password"'';
            example = lib.literalExpression ''config.sops.secrets._agent_mesh_mqtt_password.path'';
            description = ''
              A file containing the broker password, and nothing else.

              Named rather than inlined: the generated config.toml is an ordinary
              world-readable file, so a password written into it would undo what
              sops-nix is for. agent-mesh reads the file at the moment it needs
              the credential.
            '';
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
