{
  config,
  lib,
  ...
}:

let
  cfg = config.soxincfg.programs.claude-code;
  homePath = config.home.homeDirectory;

  sopsFile = ./home.sops.yaml;
in
{
  config = lib.mkIf cfg.enable {
    sops.secrets = {
      _claude_minimax_auth_token = {
        inherit sopsFile;

        path = "${homePath}/.claude/minimax-token";
      };
    };
  };
}
