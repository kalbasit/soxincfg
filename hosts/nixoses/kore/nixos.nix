{
  config,
  lib,
  pkgs,
  soxincfg,
  ...
}:

let
  sopsFile = ./secrets.sops.yaml;
in
{
  imports = [
    soxincfg.nixosModules.profiles.miniserver

    ./hardware-configuration.nix

    ./mjpg-streamer.nix
  ];

  # nixpkgs.config.allowUnfree = true;
  nixpkgs.system = "aarch64-linux";

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
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKBOvTyKSvp4vENrpyFKkZ+OfBBeSXRvR7CWhPBHbGD19Xev+gAF/D1y5zqdaEK6sZuSmWoBfLHatbfWjiz6Yj1uygYtDilyqSaw0tkdsOMihMHtqvkdNugrzPyfyeugdGUPG50tnXbkTyp8QOfxhkqdpwku0NMLMnMDMOKjGzdYlEFvdPANnjiS2FTrDRbTvb4B64t9OgQ0d/tUpuTMRvRSoTLBtlJC5nNFhNKnhDl6lZDMTQyTZSg8iA25W2C2KQVs5IKJ+E+LMS7golD3t1i/S9kN4guo7yoEU5lQ8xGBqDX5Gnqwl1wriKJP1roIS0tqi9yHCSX18oeyotY7Y3mWg5lIwotgOBYJ3X5IIH1L0oG92aK5dyGedoDUUMZ8GcRX98PqW8WUa0lZRaYyPfmpN5tzhJpKaqwtdKhxgMyESx0UUFTmUwPPgTVvd4gb0P989BguwKKggx591FzGOHVpWwoYcR9S4q+3F+bSzxKFAOet8CARPP2f3v3ULG6pjSycrvy16BMnzIr1kUmlzBQfhFhqa0HR6I9VQu1ND2SOZPz11wTE7zdOWMV68A47tvvemCOM9GSHLATbTeDnZNWwVAICUslkYiiLULTev07bh5OuwQfY+IK0IeCZ4Wsvy52nWz1YsVmLcwPqPCpsi0oqyhEFzBpfhMwATWlaSiQw== Kore Builder"
      ];
      isNormalUser = true;
    };
  };

  # define the networking by hand
  sops.secrets."networking.wireless.environmentFile" = {
    inherit sopsFile;
  };
  networking.wireless = {
    enable = true;
    environmentFile = config.sops.secrets."networking.wireless.environmentFile".path;
    networks = {
      "Nasreddine-ServerNetwork0" = {
        psk = "@PSK_NASREDDINE_SERVERNETWORK0@";
      };
    };
  };

  system.stateVersion = "23.05";
}
