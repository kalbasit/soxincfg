{
  config,
  hostType,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.soxincfg.programs.codex;
in
{
  imports = [
    (import ../../agent/skills {
      inherit (cfg) enable;

      addSkill = name: body: {
        home.file.".agents/skills/${name}/SKILL.md".text = body;
      };
    })
  ];

  config = lib.mkIf cfg.enable {
    programs.codex.enable = true;
  };
}
