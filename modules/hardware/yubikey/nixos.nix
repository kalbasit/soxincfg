{
  mode,
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkIf;

  inherit (pkgs)
    yubico-piv-tool
    yubikey-manager
    yubikey-personalization
    yubikey-personalization-gui
    yubioath-desktop
    ;

  cfg = config.soxincfg.hardware.yubikey;
in
{
  config = mkIf cfg.enable {
    environment.systemPackages = [
      yubico-piv-tool
      yubikey-manager
      yubikey-personalization
      yubikey-personalization-gui
      yubioath-desktop
    ];

    programs.gnupg.agent = mkIf cfg.gnupg-support.enable {
      enable = true;

      enableSSHSupport = cfg.gnupg-support.ssh-support.enable;
      enableExtraSocket = cfg.gnupg-support.extra-socket;
    };

    services.pcscd.enable = true;
  };
}
