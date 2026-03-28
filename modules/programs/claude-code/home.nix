{
  config,
  hostType,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.soxincfg.programs.claude-code;

  claude-code-provider = pkgs.writeShellApplication {
    name = "claude-code-provider";
    runtimeInputs = [ config.programs.claude-code.package ];
    text = ''
      PROVIDER="anthropic" # Default provider

      # Intercept and shift the provider flag if it's the first argument
      if [[ "''${1:-}" == "--minimax" ]]; then
          PROVIDER="minimax"
          shift
      elif [[ "''${1:-}" == "--anthropic" ]]; then
          PROVIDER="anthropic"
          shift
      fi

      if [[ "$PROVIDER" == "minimax" ]]; then
          export ANTHROPIC_BASE_URL="https://api.minimax.io/anthropic"
          export ANTHROPIC_DEFAULT_HAIKU_MODEL="MiniMax-M2.7"
          export ANTHROPIC_DEFAULT_OPUS_MODEL="MiniMax-M2.7"
          export ANTHROPIC_DEFAULT_SONNET_MODEL="MiniMax-M2.7"
          export ANTHROPIC_MODEL="MiniMax-M2.7"
          export ANTHROPIC_SMALL_FAST_MODEL="MiniMax-M2.7"
          export API_TIMEOUT_MS="3000000"
          export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC="1"

          # Securely load the token to avoid leaking it in the Nix store
          if [[ -f "$HOME/.claude/minimax-token" ]]; then
              ANTHROPIC_AUTH_TOKEN="$(cat "$HOME/.claude/minimax-token")"
              export ANTHROPIC_AUTH_TOKEN
          elif [[ -z "''${ANTHROPIC_AUTH_TOKEN:-}" ]]; then
              echo "Error: ANTHROPIC_AUTH_TOKEN is not set and $HOME/.claude/minimax-token is missing." >&2
              exit 1
          fi
      else
          # Unset variables to ensure native Anthropic/Pro session works without interference
          unset ANTHROPIC_AUTH_TOKEN \
            ANTHROPIC_BASE_URL \
            ANTHROPIC_DEFAULT_HAIKU_MODEL \
            ANTHROPIC_DEFAULT_OPUS_MODEL \
            ANTHROPIC_DEFAULT_SONNET_MODEL \
            ANTHROPIC_MODEL \
            ANTHROPIC_SMALL_FAST_MODEL \
            API_TIMEOUT_MS \
            CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC
      fi

      exec claude "$@"
    '';
  };
in
{
  imports = [
    (import ../../agent/skills {
      inherit (cfg) enable;

      addSkill = name: body: {
        home.file.".claude/skills/${name}/SKILL.md".text = body;
      };
    })
  ]
  ++ lib.optionals (hostType == "nix-darwin") [ ./home-darwin.nix ];

  config = lib.mkIf cfg.enable {
    programs = {
      claude-code.enable = true;
      zsh = {
        initContent = ''
          eval "$(${pkgs.worktrunk}/bin/wt config shell init zsh)"
        '';

        shellAliases = {
          ccp = "claude-code-provider";
        };
      };
    };

    home.packages = [
      claude-code-provider

      pkgs.claude-mergetool
      pkgs.claude-monitor
      pkgs.nodejs
      pkgs.openspec
      pkgs.worktrunk
    ];
    home.sessionVariables = {
      OPENSPEC_TELEMETRY = "0";
    };
  };
}
