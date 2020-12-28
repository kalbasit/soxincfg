{ config, lib, pkgs, ... }:
with lib;
let
  nasIP = "192.168.50.2";

  buildVM = pkgs.callPackage ./build-vm.nix { };

  buildWin10VM = env:
    let
      vmName =
        if env == "prod" then "win10"
        else if env == "staging" then "win10.staging"
        else abort "${env} is not supported";

      xml = pkgs.substituteAll {
        src = ./win10.xml;

        name = vmName;

        mac_address =
          if env == "prod" then "52:54:00:54:35:95"
          else if env == "staging" then "02:68:b3:29:da:98"
          else abort "${env} is not supported";

        dev_path =
          if env == "prod" then "/dev/disk/by-path/ip-${nasIP}:3260-iscsi-iqn.2018-11.com.nasreddine.apollo:win10-lun-1"
          else if env == "staging" then "/dev/disk/by-path/ip-${nasIP}:3260-iscsi-iqn.2018-11.com.nasreddine.apollo:win10.staging-lun-1"
          else abort "${env} is not supported";

        source_dev = "ifcsn0";
      };
    in
    buildVM { inherit vmName xml; };
in
{
  systemd.services.libvirtd-guest-win10 = buildWin10VM "prod";
  # systemd.services.libvirtd-guest-win10-staging = buildWindows10 "staging";
}
