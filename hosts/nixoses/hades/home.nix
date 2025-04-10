# home-manager configuration for user `yl`
{ soxincfg }:
{
  config,
  pkgs,
  home-manager,
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
    >&2 echo "Moving TV workspace to the monitor on the right (DP-3)"
    ${getBin pkgs.i3}/bin/i3-msg "workspace tv; move workspace to output DP-2"
  '';

  programs.autorandr.profiles =
    let
      DP-2 = "00ffffffffffff0010acb9a0554e3132331c0104a53420783a0495a9554d9d26105054a54b00714f8180a940d1c0d100010101010101283c80a070b023403020360006442100001e000000ff00434656394e38434c32314e550a000000fc0044454c4c2055323431350a2020000000fd00313d1e5311000a20202020202001dd02031cf14f9005040302071601141f12132021222309070783010000023a801871382d40582c450006442100001e011d8018711c1620582c250006442100009e011d007251d01e206e28550006442100001e8c0ad08a20e02d10103e96000644210000180000000000000000000000000000000000000000000000000000000c";
      DP-3 = "00ffffffffffff001e6de25a28530600071a0103805022788eca95a6554ea1260f50542108007140818081c0a9c0b300d1c081000101e77c70a0d0a0295030203a00204f3100001a9d6770a0d0a0225030203a00204f3100001a000000fd00383d1e5a20000a202020202020000000fc004c4720554c545241574944450a011a02031e742309060749100403011f13595a128301000067030c001000183c9f3d70a0d0a0155030203a00204f3100001a7e4800e0a0381f4040403a00204f31000018011d007251d01e206e285500204f3100001e8c0ad08a20e02d10103e9600204f3100001800000000000000000000000000000000000000000000000000c5";
      eDP-1 = "00ffffffffffff0006afed6000000000001a0104952213780232a5a555529d260b505400000001010101010101010101010101010101143780a670382e406c30aa0058c11000001a102c80a670382e406c30aa0058c11000001a000000fe004a52385033804231353648414e00000000000041029e001000000a010a2020001b";
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
            rate = "60.03";
          };
        };
      };

      "wide+vertical" = {
        fingerprint = {
          inherit DP-2 DP-3;
        };

        config = {
          eDP-1.enable = false;

          DP-2 = {
            crtc = 2;
            enable = true;
            position = "3440x0";
            mode = "1920x1200";
            gamma = "1.0:0.909:0.909";
            rate = "59.95";
            rotate = "left";
          };

          DP-3 = {
            crtc = 0;
            enable = true;
            gamma = "1.0:0.909:0.909";
            mode = "3440x1440";
            position = "0x320";
            primary = true;
            rate = "59.97";
          };
        };
      };

      "internal+wide+vertical" = {
        fingerprint = {
          inherit eDP-1 DP-2 DP-3;
        };

        config = {
          eDP-1 = {
            enable = true;
            position = "760x1760";
            mode = "1920x1080";
            gamma = "1.0:0.909:0.909";
            rate = "60.03";
          };

          DP-2 = {
            crtc = 2;
            enable = true;
            position = "3440x0";
            mode = "1920x1200";
            gamma = "1.0:0.909:0.909";
            rate = "59.95";
            rotate = "left";
          };

          DP-3 = {
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
