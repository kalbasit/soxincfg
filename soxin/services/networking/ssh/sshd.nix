{ mode, config, pkgs, lib, ... }:

with lib;
let
  cfg = config.soxin.services.openssh;
in
{
  options = {
    soxin.services.openssh = {
      enable = mkEnableOption ''
        Whether to enable the OpenSSH secure shell daemon, which allows secure
        remote logins.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      services.openssh = {
        enable = true;
        passwordAuthentication = false;
        extraConfig = ''
          StreamLocalBindUnlink yes
        '';
      };
    })
  ]);
}
