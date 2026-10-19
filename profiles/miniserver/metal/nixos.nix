{
  imports = [ ../common/nixos.nix ];

  config = {
    services.fwupd.enable = true;
  };
}
