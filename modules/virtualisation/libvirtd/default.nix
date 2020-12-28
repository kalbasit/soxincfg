{ mode, soxincfg, config, lib, pkgs, modulesPath, ... }:

with lib;
let
  cfg = config.soxincfg.virtualisation.libvirtd;

  images.nixos.source = "${import ./nixos-image.nix { inherit soxincfg pkgs modulesPath; system = "x86_64-linux"; }}/image.qcow2";
in
{
  options = {
    soxincfg.virtualisation.libvirtd = {
      enable = mkEnableOption "libvirtd";
      images = mkOption {
        type = with types; listOf (enum [ "nixos" ]);
        default = [ ];
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    { soxin.virtualisation.libvirtd.enable = true; }

    (optionalAttrs (mode == "NixOS") {
      environment.etc = listToAttrs (map (image: nameValuePair ("libvirtd/base-images/${image}.qcow2") images.${image}) cfg.images);
    })
  ]);
}
