{
  config,
  lib,
  ...
}:

let
  inherit (lib)
    mkIf
    singleton
    ;

  cfg = config.soxincfg.programs.neovim;
in
{
  config = mkIf cfg.enable {
    home = {
      sessionVariables.EDITOR = "nvim";
      packages = singleton cfg.package;
    };
  };
}
