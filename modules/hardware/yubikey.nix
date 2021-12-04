{ mode, config, pkgs, lib, ... }:

with lib;
let
  cfg = config.soxincfg.hardware.yubikey;
in
{
  options = {
    soxincfg.hardware.yubikey = {
      enable = mkEnableOption "Whether to enable Yubikey.";

      ssh-public-certificate-pem = mkOption {
        apply = value: if builtins.isPath value then value else pkgs.writeText "id_rsa.pub" value;
        type = types.nullOr (types.oneOf [ types.lines types.path ]);
        default = null;
        description = ''
          The public certificate of the SSH key.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    soxin.hardware.yubikey.enable = true;

    soxincfg.programs.ssh = mkIf (cfg.ssh-public-certificate-pem != null) {
      identitiesOnly = mkDefault true;
      identityFiles = singleton (pkgs.writeText "id_rsa.pub" cfg.ssh-public-certificate-pem);
    };

    soxin.services.gpgAgent.enable = mkDefault true;
    soxin.services.gpgAgent.ssh-support.enable = mkDefault (cfg.ssh-public-certificate-pem != null);
  };
}
