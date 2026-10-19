# soxin.hardware.yubikey from Soxin's library, imported one level down where
# soxincfg's own module was, and soxincfg's addition: the key's SSH
# certificate in soxincfg's SSH client configuration.
{
  config,
  inputs,
  lib,
  ...
}:

let
  cfg = config.soxin.hardware.yubikey;
in
{
  imports = [
    ./aliases.nix
    inputs.soxin.lib.library.darwin.hardware-yubikey
  ];

  config = lib.mkIf cfg.enable {
    soxincfg.programs.ssh = lib.mkIf cfg.gnupg-support.ssh-support.enable {
      addKeysToAgent = lib.mkDefault false;
      identityFiles = lib.mkIf (cfg.gnupg-support.ssh-support.public-certificate-pem != null) (
        lib.singleton cfg.gnupg-support.ssh-support.public-certificate-pem
      );
    };
  };
}
