{ config, soxincfg, modulesPath, ... }:
{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.work.keeptruckin
    soxincfg.nixosModules.profiles.workstation.nixos.remote

    "${modulesPath}/virtualisation/amazon-image.nix"
  ];

  ec2.hvm = true;

  # Setup the builder account
  nix.settings.trusted-users = [ "root" "@wheel" "@builders" ];
  users.users = {
    builder = {
      extraGroups = [ "builders" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDjhnmrsTOc7aMZE5LYv3R/CMYVWyebxlGZV8+hUreK5YeAMnORP+d7EHtOoQlwaKAcX6U0Ty756tpamqKU4RAGSbayEfP2Z7rhLpv9aJmnXWDkdhO7TD/l3NrDpTF0La8Hzl9CiDu39Njm2/8ALIzOGYaGbWD8FkYsdAYELOvFPNM7jVZxGikokYD5Qq+ShkN/uQ2gXog9lFUpn+ubtZGUh+VO2g+FZ90mwHV9mQZehYXLH3CQJUZz8aiEg8xuDxOSlAR1xE2k0MbTQhssh0rMtEWrF0ISJsbF4Cq+9tc7cOfFCcxUsfsj7BykMleWRfQkiZmLlro+euxwkVn7zOcYoxHizJHkwymfsFaQkESfREVWmUv88A+h5EyUHDeep3DayuikMRreJq5Ntfs4BsHJC/+BOoqWxkiImMZ/I3kcS0FXIhWTOVuUHETInYwx4bbfQImlNlxKjRWt5LtVhS+LrYJVs1rP7nTiHkhi0QupW21hGD/frd/AXcARNbojc4nTRc6Tr2opjP60mtyPhxxZvY2hIWXxgiC2+QhQlc6Vr+dfmXpOPYNQ2jlWRXjKNr5fTFTj5J7+SjDQ51tygKhmnMDTF5wB5wbIM9f7WmA63Ou33ttn+HFDdZTAvbdM0jW13fSBO7dKz47FqmONRPPFDMJGSaD5HeQfevcUXy+fHQ== x86-64-linux-0"
      ];
      isNormalUser = true;
    };
  };

  # load YL's home-manager configuration
  home-manager.users.yl = import ./home.nix { inherit soxincfg; };

  system.stateVersion = "20.09";
}
