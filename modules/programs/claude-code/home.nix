{
  config,
  lib,
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
    programs.claude-code.enable = true;
  };
}
