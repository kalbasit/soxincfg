{
  config,
  lib,
  ...
}:

let
  cfg = config.soxincfg.programs.claude-code;
in
{
  imports = [ ./skills ];

  config = lib.mkIf cfg.enable {
    programs.claude-code.enable = true;
  };
}
