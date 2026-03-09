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
      baseDir = ".claude/skills";
    })
  ];

  config = lib.mkIf cfg.enable {
    programs.claude-code.enable = true;
  };
}
