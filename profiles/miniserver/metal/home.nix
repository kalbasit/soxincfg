{
  imports = [ ../common/home.nix ];

  config = {
    services.fwupd.enable = true;
  };
}
