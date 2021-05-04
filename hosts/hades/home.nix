# home-manager configuration for user `yl`
{ soxincfg }:
{ config, pkgs, home-manager, lib, ... }:

with lib;

{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.work.keeptruckin
    soxincfg.nixosModules.profiles.workstation
  ];

  # Setup the name of the wireless interface in Polybar
  soxin.services.xserver.windowManager.bar.modules.network.wlan = singleton "wlp110s0";

  # Make sure GnuPG is able to pick up the right card (Yubikey)
  home.file.".gnupg/scdaemon.conf".text = ''
    reader-port Yubico YubiKey FIDO+CCID 01 00
    disable-ccid
    card-timeout 5
  '';

  # Setup autorandr postswitch
  soxincfg.programs.autorandr.postswitch.move-workspaces-to-main = ''
    # Move the Slack workspace to the internal screen
    ${getBin pkgs.i3}/bin/i3-msg "workspace slack; move workspace to output eDP-1"

    # Move the Signal workspace to the internal screen
    ${getBin pkgs.i3}/bin/i3-msg "workspace signal; move workspace to output eDP-1"

    # Move the Keybase workspace to the internal screen
    ${getBin pkgs.i3}/bin/i3-msg "workspace keybase; move workspace to output eDP-1"

    # Move the Element workspace to the internal screen
    ${getBin pkgs.i3}/bin/i3-msg "workspace element; move workspace to output eDP-1"

    # Move the TV workspace to the internal screen
    ${getBin pkgs.i3}/bin/i3-msg "workspace tv; move workspace to output DP-3"

    # Go to my personal workspace
    ${getBin pkgs.i3}/bin/i3-msg "workspace personal"
  '';

  programs.autorandr.profiles = {
    "default" = {
      fingerprint = {
        eDP-1 = "00ffffffffffff0006afed6000000000001a0104952213780232a5a555529d260b505400000001010101010101010101010101010101143780a670382e406c30aa0058c11000001a102c80a670382e406c30aa0058c11000001a000000fe004a52385033804231353648414e00000000000041029e001000000a010a2020001b";
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

    "mancave" = {
      fingerprint = {
        DP-2 = "00ffffffffffff001e6de25a28530600071a0104a55022789eca95a6554ea1260f50542108007140818081c0a9c0b300d1c081000101e77c70a0d0a0295030203a00204f3100001a9d6770a0d0a0225030203a00204f3100001a000000fd00383d1e5a20000a202020202020000000fc004c4720554c545241574944450a01e4020316712309060749100403011f13595a12830100009f3d70a0d0a0155030203a00204f3100001a7e4800e0a0381f4040403a00204f31000018011d007251d01e206e285500204f3100001e8c0ad08a20e02d10103e9600204f31000018000000000000000000000000000000000000000000000000000000000000000000aa";
        DP-3 = "00ffffffffffff0010acbca04c3934322f1c010380342078ea0495a9554d9d26105054a54b00714f8180a940d1c0d100010101010101283c80a070b023403020360006442100001e000000ff00434656394e38424b3234394c0a000000fc0044454c4c2055323431350a2020000000fd00313d1e5311000a202020202020018c020322f14f9005040302071601141f12132021222309070765030c00200083010000023a801871382d40582c450006442100001e011d8018711c1620582c250006442100009e011d007251d01e206e28550006442100001e8c0ad08a20e02d10103e960006442100001800000000000000000000000000000000000000000072";
        eDP-1 = "00ffffffffffff0006afed6000000000001a0104952213780232a5a555529d260b505400000001010101010101010101010101010101143780a670382e406c30aa0058c11000001a102c80a670382e406c30aa0058c11000001a000000fe004a52385033804231353648414e00000000000041029e001000000a010a2020001b";
      };

      config = {
        DP-3 = {
          # crtc = 2;
          enable = true;
          position = "0x0";
          mode = "1920x1200";
          gamma = "1.0:0.909:0.909";
          rate = "59.95";
          rotate = "right";
        };

        DP-2 = {
          # crtc = 0;
          enable = true;
          gamma = "1.0:0.909:0.909";
          mode = "3440x1440";
          position = "1200x480";
          primary = true;
          rate = "59.97";
        };

        eDP-1 = {
          # crtc = 1;
          enable = true;
          gamma = "1.0:0.909:0.909";
          mode = "1920x1080";
          position = "4640x840";
          rate = "60.03";
          scale = {
            method = "factor";
            x = 0.8;
            y = 0.8;
          };
        };
      };
    };
  };
}
