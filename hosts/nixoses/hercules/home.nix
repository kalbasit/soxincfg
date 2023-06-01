# home-manager configuration for user `yl`
{ soxincfg }:
{ config, pkgs, home-manager, lib, ... }:

with lib;

{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.work.keeptruckin
    soxincfg.nixosModules.profiles.workstation.nixos.local
  ];

  # Setup the name of the wireless interface in Polybar
  soxin.services.xserver.windowManager.bar.modules.network.wlan = singleton "wlp110s0";


  # Make sure GnuPG is able to pick up the right card (Yubikey)
  programs.gpg.scdaemonSettings =
    mkIf (config.soxincfg.hardware.yubikey.enable && config.soxincfg.hardware.yubikey.gnupg-support.enable) {
      reader-port = "Yubico YubiKey FIDO+CCID 01 00";
      disable-ccid = true;
      card-timeout = "5";
    };

  # Setup autorandr postswitch
  soxincfg.programs.autorandr.postswitch.move-workspaces-to-main = ''
    # Move the TV workspace to the right screen
    >&2 echo "Moving TV workspace to the monitor on the right (DP-3)"
    ${getBin pkgs.i3}/bin/i3-msg "workspace tv; move workspace to output DP-3"
  '';

  programs.autorandr.profiles =
    let
      eDP-1 = "00ffffffffffff0009e5df0800000000251d0104a52213780754a5a7544c9b260f505400000001010101010101010101010101010101988980a0703860403020360058c21000001a000000000000000000000000000000000000000000fe00424f452043510a202020202020000000fe004e5631353646484d2d4e59340a00fd";
      DP-2 = "00ffffffffffff001e6de25a28530600071a0104a55022789eca95a6554ea1260f50542108007140818081c0a9c0b300d1c081000101e77c70a0d0a0295030203a00204f3100001a9d6770a0d0a0225030203a00204f3100001a000000fd00383d1e5a20000a202020202020000000fc004c4720554c545241574944450a01e4020316712309060749100403011f13595a12830100009f3d70a0d0a0155030203a00204f3100001a7e4800e0a0381f4040403a00204f31000018011d007251d01e206e285500204f3100001e8c0ad08a20e02d10103e9600204f31000018000000000000000000000000000000000000000000000000000000000000000000aa";
    in
    {
      "default" = {
        fingerprint = { inherit eDP-1; };

        config = {
          eDP-1 = {
            enable = true;
            primary = true;
            position = "0x0";
            mode = "1920x1080";
            gamma = "1.0:0.909:0.909";
            rate = "60.01";
          };
        };
      };


      "internal+wide" = {
        fingerprint = { inherit eDP-1 DP-2; };

        config = {
          eDP-1.enable = false;

          DP-2 = {
            enable = true;
            gamma = "1.0:0.909:0.909";
            mode = "3440x1440";
            position = "0x320";
            primary = true;
            rate = "59.97";
          };
        };
      };

      "wide" = {
        fingerprint = { inherit DP-2; };

        config = {
          DP-2 = {
            enable = true;
            gamma = "1.0:0.909:0.909";
            mode = "3440x1440";
            position = "0x320";
            primary = true;
            rate = "59.97";
          };
        };
      };
    };

  home.stateVersion = "22.11";
}
