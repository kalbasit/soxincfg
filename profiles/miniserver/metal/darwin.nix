{
  imports = [ ../common/darwin.nix ];

  config = {
    services.fwupd.enable = true;
  };
}
