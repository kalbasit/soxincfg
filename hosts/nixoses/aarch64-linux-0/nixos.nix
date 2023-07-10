{ config, soxincfg, modulesPath, ... }:
{
  imports = [
    soxincfg.nixosModules.profiles.server

    # TODO: Getting an error because delve does not build on this arch which is required for NeoVim
    soxincfg.nixosModules.profiles.myself
    # soxincfg.nixosModules.profiles.workstation.nixos.remote

    "${modulesPath}/virtualisation/amazon-image.nix"
  ];
  # ++ (soxincfg.nixosModules.profiles.work.imports { hostName = "aarch64-linux-0"; });

  ec2.hvm = true;
  ec2.efi = true;

  # Setup the builder account
  nix.settings.trusted-users = [ "root" "@wheel" "@builders" ];
  users.users = {
    builder = {
      extraGroups = [ "builders" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDt0XT8J0AcRf2TmYGLF1rRDszxGpmtGYXScriykNocR4HGvjndVjzpf/nnonpNuaPmlV9pS+mUg63jqYNT4o2ofk9BBYTgnitPzcyt9RGaeTDMlNNmK/Vq8yDUH3S9AQcvOua9Y9vqKmxC3J+Ylkl22wV95hHByoRz8BH5skbSDE5tD+d66rCiVb/rb6gQrfE+oWjB+Zwl/q8hbJal+J1WzWkOfeDnI06crcbMUmdZIS1rqOWK4PCYAWs7bku7d2nIB9f0oUgD8OfeK35FGBTdeXZebjTNcmeIFUf9D4v3fH+5L9j/W/eHX5OCV99aiu9EDDS1V9JwSe2iIjaeKEBoYsUOSQ91/UQ9yxN8YJ6ii/ZdPVRaKpmk3pTtjyYUpIFyyxf8XgquFOdYLPENIdaiQYAf2XLS8/0lybHI7Yel5aS5fzsV6/aOIlTSeDG/IHe9XQlk6d6ILnBkiizzOxpivTrCJHD1wdI5eSlQ+gSnbsPq8qTanKdQDbw80kbl2HByOoXtbF/r7r5KEb1niyriLVYuAyvh2Cu4/6oK9qukQhTpy6yoj4zx+yvvCxPK+2dzQoWlyrfx2UlHna7f9AfHbqKJtalicJ0A+vfg53USBn2y1S/KDV+zX8IVw0xQK/0xrKcAuRMt8ib1P/ShVMGa9wR5a+kzY/wCQayz/Q06pQ== aarch64-linux-0"
      ];
      isNormalUser = true;
    };
  };

  # load YL's home-manager configuration
  # TODO: Getting an error because delve does not build on this arch which is required for NeoVim
  # home-manager.users.yl = import ./home.nix { inherit soxincfg; };

  system.stateVersion = "23.05";
}
