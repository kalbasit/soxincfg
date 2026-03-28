{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.soxincfg.programs.claude-code;
in
{
  imports = [
    (import ../../agent/skills {
      inherit (cfg) enable;

      addSkill = name: body: {
        home.file.".claude/skills/${name}/SKILL.md".text = body;
      };
    })
  ];

  config = lib.mkIf cfg.enable {
    programs = {
      claude-code.enable = true;
      zsh.initContent = ''
        eval "$(${pkgs.worktrunk}/bin/wt config shell init zsh)"
      '';
    };

    home.packages = [
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
