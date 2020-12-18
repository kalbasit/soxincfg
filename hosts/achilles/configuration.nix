{ soxincfg, ... }:
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
      mosh.enable = true;
      ssh.enable = true;
      starship.enable = true;
      zsh.enable = true;
    };

    services = {
      gpgAgent.enable = true;
      openssh.enable = true;
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

  security.pki.certificates = [
    nasreddineCA
  ];

  system.stateVersion = "20.09"; # Did you read the comment?
}
