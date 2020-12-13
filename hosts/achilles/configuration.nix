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

  # define the users
  soxin.users.users = {
    yl = {
      inherit (soxincfg.vars.users.yl) hashedPassword sshKeys uid;
      isAdmin = true;
      home = "/yl";
    };
  };
  users.users.root.openssh.authorizedKeys.keys = soxincfg.vars.users.yl.sshKeys;

  # load yl's home-manager configuration
  home-manager.users.yl = import ./home.nix { inherit soxincfg; };

  soxin = {
    settings = {
      keyboard = {
        layouts = [
          {
            x11 = { layout = "us"; variant = "colemak"; };
            console = { keyMap = "colemak"; };
          }
        ];
      };
    };
  };

  boot.tmpOnTmpfs = true;

  # set the default locale and the timeZone
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Los_Angeles";

  # soxin.hardware.intel_backlight.enable = true;
  # soxin.printing.enable = true;
  soxin.virtualisation.docker.enable = true;
  soxin.virtualisation.libvirtd.enable = true;

  services.xserver.libinput.enable = true;
  services.xserver.libinput.accelSpeed = "0.5";

  services.logind.extraConfig = ''
    HandlePowerKey=suspend
  '';

  security.pki.certificates = [
    nasreddineCA
  ];

  system.stateVersion = "20.09"; # Did you read the comment?
}
