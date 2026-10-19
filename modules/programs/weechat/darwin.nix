{
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let
  cfg = config.soxincfg.programs.weechat;

  weechat-home =
    with pkgs;
    stdenvNoCC.mkDerivation {
      name = "weechat-home";
      src = ./config;
      unpackPhase = ":";

      preferLocalBuild = true;
      allowSubstitutes = false;

      installPhase = ''
        mkdir $out

        ln -s ${config.home.homeDirectory}/.weechat/buddylist.txt $out/buddylist.txt
        ln -s ${config.home.homeDirectory}/.weechat/logs $out/logs
        ln -s ${config.home.homeDirectory}/.weechat/urlserver_list.txt $out/urlserver_list.txt
        ln -s ${config.home.homeDirectory}/.weechat/weechat.log $out/weechat.log

        ${rsync}/bin/rsync --exclude '*.sops' -avz $src/ $out/
      '';
    };

  owner = config.soxincfg.settings.users.user.name;
in
{
  options = {
    soxincfg.programs.weechat = {
      enable = mkEnableOption "WeeChat IRC client";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    { }

    { }
  ]);
}
