{ config, pkgs, home-manager, lib, soxincfg, ... }:

with lib;

{
  imports = [
    # soxincfg.nixosModules.profiles.myself
    # soxincfg.nixosModules.profiles.work.keeptruckin
    # soxincfg.nixosModules.profiles.workstation.chromeos.local
  ];

  soxin.keyboard.layouts = [
            {
              x11 = { layout = "us"; variant = "colemak"; };
              console = { keyMap = "colemak"; };
            }
          ];

  # # Make sure GnuPG is able to pick up the right card (Yubikey)
  # home.file.".gnupg/scdaemon.conf".text = ''
  #   reader-port Yubico YubiKey FIDO+CCID 01 00
  #   disable-ccid
  #   card-timeout 5
  # '';
}
