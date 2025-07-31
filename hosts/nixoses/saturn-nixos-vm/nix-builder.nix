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
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJT4Z6djPh1KjuNBl2vkV33Y5UVJFCaq84/cbKKkTjvD Saturn NixOS VM Builder"
      ];
      isNormalUser = true;
    };
  };
}
