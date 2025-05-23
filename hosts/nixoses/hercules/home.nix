# home-manager configuration for user `yl`
{ soxincfg }:
{
  config,
  pkgs,
  home-manager,
  inputs,
  lib,
  ...
}:

with lib;

{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.personal
    soxincfg.nixosModules.profiles.workstation.nixos.local
  ];

  # Setup the name of the wireless interface in Polybar
  soxin.services.xserver.windowManager.bar.modules.network.wlan = singleton "wlp110s0";

  # Make sure GnuPG is able to pick up the right card (Yubikey)
  programs.gpg.scdaemonSettings =
    mkIf
      (config.soxincfg.hardware.yubikey.enable && config.soxincfg.hardware.yubikey.gnupg-support.enable)
      {
        reader-port = "Yubico YubiKey FIDO+CCID 01 00";
        disable-ccid = true;
        card-timeout = "5";
      };

  # Setup autorandr postswitch
  soxincfg.programs.autorandr.postswitch.move-workspaces-to-main = ''
    # Move the TV workspace to the right screen
    >&2 echo "Moving TV workspace to the monitor on the right (HDMI-0)"
    ${getBin pkgs.i3}/bin/i3-msg "workspace tv; move workspace to output HDMI-0"
  '';

  programs.autorandr.profiles =
    let
      DP-2 = "00ffffffffffff001e6de25a28530600071a0104a55022789eca95a6554ea1260f50542108007140818081c0a9c0b300d1c081000101e77c70a0d0a0295030203a00204f3100001a9d6770a0d0a0225030203a00204f3100001a000000fd00383d1e5a20000a202020202020000000fc004c4720554c545241574944450a01e4020316712309060749100403011f13595a12830100009f3d70a0d0a0155030203a00204f3100001a7e4800e0a0381f4040403a00204f31000018011d007251d01e206e285500204f3100001e8c0ad08a20e02d10103e9600204f31000018000000000000000000000000000000000000000000000000000000000000000000aa";
      HDMI-0 = "00ffffffffffff0010acb9a0554e3132331c0103803420780a0495a9554d9d26105054a54b00714f8180a940d1c0d100010101010101283c80a070b023403020360006442100001e000000ff00434656394e38434c32314e550a000000fc0044454c4c2055323431350a2020000000fd00313d1e5311000a2020202020200133020324f44f9005040302071601141f1213202122230907078301000067030c001000183c023a801871382d40582c450006442100001e011d8018711c1620582c250006442100009e011d007251d01e206e28550006442100001e8c0ad08a20e02d10103e96000644210000180000000000000000000000000000000000000027";
      eDP-1 = "00ffffffffffff0009e5df0800000000251d0104a52213780754a5a7544c9b260f505400000001010101010101010101010101010101988980a0703860403020360058c21000001a000000000000000000000000000000000000000000fe00424f452043510a202020202020000000fe004e5631353646484d2d4e59340a00fd";
    in
    {
      "default" = {
        fingerprint = {
          inherit eDP-1;
        };

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

      "wide+vertical" = {
        fingerprint = {
          inherit DP-2 HDMI-0;
        };

        config = {
          HDMI-0 = {
            crtc = 2;
            enable = true;
            position = "3440x0";
            mode = "1920x1200";
            gamma = "1.0:0.909:0.909";
            rate = "59.95";
            rotate = "left";
          };

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

  home.stateVersion = "23.05";
}
