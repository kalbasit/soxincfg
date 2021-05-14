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

  # Make sure GnuPG is able to pick up the right card (Yubikey)
  home.file.".gnupg/scdaemon.conf".text = ''
    reader-port Yubico YubiKey FIDO+CCID 01 00
    disable-ccid
    card-timeout 5
  '';
}
