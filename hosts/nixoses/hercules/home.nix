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

  # programs.autorandr.profiles =
  #   let
  #     eDP-1 = "00ffffffffffff0006afed6000000000001a0104952213780232a5a555529d260b505400000001010101010101010101010101010101143780a670382e406c30aa0058c11000001a102c80a670382e406c30aa0058c11000001a000000fe004a52385033804231353648414e00000000000041029e001000000a010a2020001b";
  #     DP-2 = "00ffffffffffff001e6de25a28530600071a0104a55022789eca95a6554ea1260f50542108007140818081c0a9c0b300d1c081000101e77c70a0d0a0295030203a00204f3100001a9d6770a0d0a0225030203a00204f3100001a000000fd00383d1e5a20000a202020202020000000fc004c4720554c545241574944450a01e4020316712309060749100403011f13595a12830100009f3d70a0d0a0155030203a00204f3100001a7e4800e0a0381f4040403a00204f31000018011d007251d01e206e285500204f3100001e8c0ad08a20e02d10103e9600204f31000018000000000000000000000000000000000000000000000000000000000000000000aa";
  #     DP-2_pbp = "00ffffffffffff001e6de25a28530600071a0104a55022789eca95a6554ea1260f50542108007140818081c0a9c0b300d1c0810001013c41b8a060a0295030203a00204f3100001a000000fd00383d1e5a20000a202020202020000000fc004c4720554c545241574944450a000000000000000000000000000000000000012c020316712309060749100403011f13595a12830100009f3d70a0d0a0155030203a00204f3100001a7e4800e0a0381f4040403a00204f31000018011d007251d01e206e285500204f3100001e8c0ad08a20e02d10103e9600204f31000018000000000000000000000000000000000000000000000000000000000000000000aa";
  #     DP-3 = "00ffffffffffff0010acbaa0554e3132331c010380342078ea0495a9554d9d26105054a54b00714f8180a940d1c0d100010101010101283c80a070b023403020360006442100001e000000ff00434656394e38434c32314e550a000000fc0044454c4c2055323431350a2020000000fd00313d1e5311000a2020202020200152020322f14f9005040302071601141f12132021222309070765030c00100083010000023a801871382d40582c450006442100001e011d8018711c1620582c250006442100009e011d007251d01e206e28550006442100001e8c0ad08a20e02d10103e960006442100001800000000000000000000000000000000000000000082";
  #     DP-3_viewsonic = "00ffffffffffff005a6339d201010101271f0103802213782edae5955d599429245054bfef80a9c095009040818081c0714f310a0101023a801871382d40582c450058c21000001e000000ff005733573231333932303431320a000000fd00324b0f5210000a202020202020000000fc005647313635350a2020202020200134020322f14f030405070f90121314161e1f20212223097f078301000065030c001000023a801871382d40582c450058c21000001e023a80d072382d40102c458058c21000001e011d007251d01e206e28550058c21000001e8c0ad08a20e02d10103e960058c210000018000000000000000000000000000000000000000000e2";
  #   in
  #   {
  #     "default" = {
  #       fingerprint = { inherit eDP-1; };
  #
  #       config = {
  #         eDP-1 = {
  #           enable = true;
  #           primary = true;
  #           position = "0x0";
  #           mode = "1920x1080";
  #           gamma = "1.0:0.909:0.909";
  #           rate = "60.03";
  #         };
  #       };
  #     };
  #
  #     "remote-office" = {
  #       fingerprint = {
  #         inherit eDP-1;
  #         DP-3 = "00ffffffffffff004c2d730b000000003317010380341d780a9791a556549d250e5054bdef80714f81c0810081809500a9c0b3000101023a801871382d40582c450009252100001e662156aa51001e30468f330009252100001e000000fd00184b0f5117000a202020202020000000fc00543234443339310a20202020200183020325f14d901f04130514031220212207162309070783010000e2000f67030c001000b82d011d007251d01e206e28550009252100001e011d8018711c1620582c250009252100009e011d00bc52d01e20b828554009252100001e011d80d0721c1620102c258009252100009e00000000000000000000000000000000000098";
  #       };
  #
  #       config = {
  #         eDP-1 = {
  #           enable = true;
  #           position = "0x0";
  #           mode = "1920x1080";
  #           gamma = "1.0:0.909:0.909";
  #           rate = "60.03";
  #         };
  #
  #         DP-3 = {
  #           enable = true;
  #           primary = true;
  #           position = "1920x0";
  #           mode = "1920x1080";
  #           gamma = "1.0:0.909:0.909";
  #           rate = "60.00";
  #         };
  #       };
  #     };
  #
  #     "internal+wide" = {
  #       fingerprint = { inherit eDP-1 DP-2; };
  #
  #       config = {
  #         eDP-1.enable = false;
  #
  #         DP-2 = {
  #           enable = true;
  #           gamma = "1.0:0.909:0.909";
  #           mode = "3440x1440";
  #           position = "0x320";
  #           primary = true;
  #           rate = "59.97";
  #         };
  #       };
  #     };
  #
  #     "wide" = {
  #       fingerprint = { inherit DP-2; };
  #
  #       config = {
  #         DP-2 = {
  #           enable = true;
  #           gamma = "1.0:0.909:0.909";
  #           mode = "3440x1440";
  #           position = "0x320";
  #           primary = true;
  #           rate = "59.97";
  #         };
  #       };
  #     };
  #
  #     "wide+vertical" = {
  #       fingerprint = { inherit DP-2 DP-3; };
  #
  #       config = {
  #         DP-3 = {
  #           crtc = 2;
  #           enable = true;
  #           position = "3440x0";
  #           mode = "1920x1200";
  #           gamma = "1.0:0.909:0.909";
  #           rate = "59.95";
  #           rotate = "left";
  #         };
  #
  #         DP-2 = {
  #           enable = true;
  #           gamma = "1.0:0.909:0.909";
  #           mode = "3440x1440";
  #           position = "0x320";
  #           primary = true;
  #           rate = "59.97";
  #         };
  #       };
  #     };
  #
  #     "internal+wide+vertical" = {
  #       fingerprint = { inherit eDP-1 DP-2 DP-3; };
  #
  #       config = {
  #         eDP-1.enable = false;
  #
  #         DP-3 = {
  #           crtc = 2;
  #           enable = true;
  #           position = "3440x0";
  #           mode = "1920x1200";
  #           gamma = "1.0:0.909:0.909";
  #           rate = "59.95";
  #           rotate = "left";
  #         };
  #
  #         DP-2 = {
  #           enable = true;
  #           gamma = "1.0:0.909:0.909";
  #           mode = "3440x1440";
  #           position = "0x320";
  #           primary = true;
  #           rate = "59.97";
  #         };
  #       };
  #     };
  #
  #     "wide_pbp+vertical" = {
  #       fingerprint = {
  #         DP-2 = DP-2_pbp;
  #         inherit DP-3;
  #       };
  #
  #       config = {
  #         DP-3 = {
  #           # crtc = 2;
  #           enable = true;
  #           position = "0x0";
  #           mode = "1920x1200";
  #           gamma = "1.0:0.909:0.909";
  #           rate = "59.95";
  #           rotate = "right";
  #         };
  #
  #         DP-2 = {
  #           enable = true;
  #           gamma = "1.0:0.909:0.909";
  #           mode = "1720x1440";
  #           position = "1200x480";
  #           primary = true;
  #           rate = "59.97";
  #         };
  #       };
  #     };
  #
  #     "internal+wide_pbp+verticale" = {
  #       fingerprint = {
  #         DP-2 = DP-2_pbp;
  #         inherit eDP-1 DP-3;
  #       };
  #
  #       config = {
  #         eDP-1.enable = false;
  #
  #         DP-3 = {
  #           # crtc = 2;
  #           enable = true;
  #           position = "0x0";
  #           mode = "1920x1200";
  #           gamma = "1.0:0.909:0.909";
  #           rate = "59.95";
  #           rotate = "right";
  #         };
  #
  #         DP-2 = {
  #           enable = true;
  #           gamma = "1.0:0.909:0.909";
  #           mode = "1720x1440";
  #           position = "1200x480";
  #           primary = true;
  #           rate = "59.97";
  #         };
  #       };
  #     };
  #
  #     "internal+viewsonic_portable" = {
  #       fingerprint = {
  #         DP-3 = DP-3_viewsonic;
  #         inherit eDP-1;
  #       };
  #
  #       config = {
  #         DP-3 = {
  #           enable = true;
  #           primary = true;
  #           position = "0x0";
  #           mode = "1920x1080";
  #           gamma = "1.0:0.909:0.909";
  #           rate = "59.95";
  #         };
  #
  #         eDP-1 = {
  #           enable = true;
  #           position = "1920x0";
  #           mode = "1920x1080";
  #           gamma = "1.0:0.909:0.909";
  #           rate = "60.03";
  #         };
  #       };
  #     };
  #   };

  home.stateVersion = "22.11";
}
