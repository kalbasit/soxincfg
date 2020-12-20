{ config, soxincfg, ... }:
let
  nasreddineCA = builtins.readFile (builtins.fetchurl {
    url = "https://s3-us-west-1.amazonaws.com/nasreddine-infra/ca.crt";
    sha256 = "17x45njva3a535czgdp5z43gmgwl0lk68p4mgip8jclpiycb6qbl";
  });
in
{
  imports = [
    soxincfg.nixosModules.profiles.workstation

    ./hardware-configuration.nix
  ];

  sops.defaultSopsFile = ./secrets.yaml;

  # Set the ssh authorized keys for the root user
  users.users.root.openssh.authorizedKeys.keys = soxincfg.vars.users.yl.sshKeys;

  # load yl's home-manager configuration
  home-manager.users.yl = import ./home.nix { inherit soxincfg; };

  soxin = {
    hardware.bluetooth.enable = true;

    hardware = {
      enable = true;
      intelBacklight.enable = true;
      sound.enable = true;
      yubikey.enable = true;
    };

    programs = {
      autorandr.enable = true;
      git.enable = true;
      htop.enable = true;
      keybase.enable = true;
      mosh.enable = true;
      ssh.enable = true;
      starship.enable = true;
      zsh.enable = true;
    };

    services = {
      gpgAgent.enable = true;
      openssh.enable = true;
      networkmanager.enable = true;
      printing = {
        enable = true;
        brands = [ "epson" ];
      };
      xserver.enable = true;
    };

    settings = {
      fonts.enable = true;
      gtk.enable = true;
      keyboard = {
        layouts = [
          {
            x11 = { layout = "us"; variant = "colemak"; };
            console = { keyMap = "colemak"; };
          }
        ];
      };
    };

    users.users = {
      yl = {
        inherit (soxincfg.vars.users.yl) hashedPassword sshKeys uid;
        isAdmin = true;
        home = "/yl";
      };
    };

    virtualisation = {
      docker.enable = true;
      libvirtd.enable = true;
    };
  };

  programs.nm-applet.enable = true;

  boot.tmpOnTmpfs = true;

  # set the default locale and the timeZone
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Los_Angeles";

  # speed up the trackpad
  services.xserver.libinput.enable = true;
  services.xserver.libinput.accelSpeed = "0.5";

  hardware.pulseaudio.zeroconf.discovery.enable = true;

  services.logind = {
    lidSwitch = "hybrid-sleep";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "hybrid-sleep";
    extraConfig = ''
      HandlePowerKey=suspend
    '';
  };

  environment.homeBinInPath = true;

  security.pki.certificates = [ nasreddineCA ];

  sops.secrets.ssh_key_zeus = { };
  sops.secrets.ssh_key_kore = { };
  nix.buildMachines = [
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
      maxJobs = 4;
      sshKey = builtins.toString config.sops.secrets.ssh_key_kore.path;
      sshUser = "builder";
      system = "aarch64-linux";
      supportedFeatures = [ ];
    }
  ];

  # TODO: fix this!
  system.extraSystemBuilderCmds = ''ln -sfn /yl/.surfingkeys.js $out/.surfingkeys.js'';

  # L2TP VPN does not connect without the presence of this file!
  # https://github.com/NixOS/nixpkgs/issues/64965
  system.activationScripts.ipsec-secrets = ''
    touch $out/etc/ipsec.secrets
  '';

  system.stateVersion = "20.09"; # Did you read the comment?
}
