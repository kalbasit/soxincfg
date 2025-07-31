{
  # Setup the builder account
  nix.settings.trusted-users = [
    "root"
    "@wheel"
    "@builders"
  ];
  users.users = {
    builder = {
      extraGroups = [ "builders" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEJujGo/YGz827JEXlCrmLBQll+JTtWGKZeHQHltjEKK Hercules Builder"
      ];
      isNormalUser = true;
    };
  };
}
