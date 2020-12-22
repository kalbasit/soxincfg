{ config, pkgs, soxincfg, ... }:
let
  nasreddineCA = builtins.readFile (builtins.fetchurl {
    url = "https://s3-us-west-1.amazonaws.com/nasreddine-infra/ca.crt";
    sha256 = "17x45njva3a535czgdp5z43gmgwl0lk68p4mgip8jclpiycb6qbl";
  });
in
{
  nix = {
    package = pkgs.nixFlakes;

    # enable the sandbox but only on Linux
    useSandbox = pkgs.stdenv.hostPlatform.isLinux;

    extraOptions = ''
      experimental-features = nix-command flakes ca-references
    '';

    buildMachines = [
      {
        hostName = "zeus.admin.nasreddine.com";
        sshUser = "builder";
        sshKey = builtins.toString config.sops.secrets.ssh_key_zeus.path;
        system = "x86_64-linux";
        maxJobs = 8;
        speedFactor = 2;
        supportedFeatures = [ ];
        mandatoryFeatures = [ ];
      }

      # {
      #   hostName = "aarch64.nixos.community";
      #   maxJobs = 64;
      #   sshKey = builtins.toString ./../../../../keys/aarch64-build-box;
      #   sshUser = "kalbasit";
      #   system = "aarch64-linux";
      #   supportedFeatures = [ "big-parallel" ];
      # }

      {
        hostName = "kore.admin.nasreddine.com";
        maxJobs = 2;
        sshKey = builtins.toString config.sops.secrets.ssh_key_kore.path;
        sshUser = "builder";
        system = "aarch64-linux";
        supportedFeatures = [ ];
      }
    ];
  };

  boot.tmpOnTmpfs = true;

  security.pki.certificates = [ nasreddineCA ];

  sops.secrets.ssh_key_zeus.sopsFile = ./secrets.sops.yaml;
  sops.secrets.ssh_key_kore.sopsFile = ./secrets.sops.yaml;

  # Set the ssh authorized keys for the root user
  users.users.root.openssh.authorizedKeys.keys = soxincfg.vars.users.yl.sshKeys;

  # set the default locale and the timeZone
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Los_Angeles";
}
