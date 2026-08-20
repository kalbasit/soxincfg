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
    };
  };
}
