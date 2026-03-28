{
  config,
  lib,
  ...
}:

let
  homePath = config.soxincfg.settings.users.user.home;
  owner = config.soxincfg.settings.users.user.name;
  sopsFile = ./home.sops.yaml;

  cfg = config.soxincfg.programs.claude-code;

in
{
  config = lib.mkIf cfg.enable {
    sops.secrets = {
      _claude_minimax_auth_token = {
        inherit owner sopsFile;

        path = "${homePath}/.claude/minimax-token";
      };
    };
  };
}
