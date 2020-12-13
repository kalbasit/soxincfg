# home-manager configuration for user `yl`
{ soxincfg }:
{ pkgs, ... }:

{
  imports = [
    soxincfg.nixosModules.profiles.workstation
  ];

  soxin = {
    settings = {
      keyboard = {
        layouts = [
          { x11 = { layout = "us"; variant = "colemak"; }; }
        ];
      };
    };
  };
}
