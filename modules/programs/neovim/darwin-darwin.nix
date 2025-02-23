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
    environment = {
      variables.EDITOR = "nvim";
      systemPackages = singleton cfg.package;
    };
  };
}
