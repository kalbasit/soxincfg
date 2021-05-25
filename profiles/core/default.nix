{ config, pkgs, soxincfg, mode, lib, ... }:
with lib;
let
  nasreddineCA = builtins.readFile (builtins.fetchurl {
    url = "https://s3-us-west-1.amazonaws.com/nasreddine-infra/ca.crt";
    sha256 = "17x45njva3a535czgdp5z43gmgwl0lk68p4mgip8jclpiycb6qbl";
  });

  colemakLayout = {
    x11 = { layout = "us"; variant = "colemak"; };
    console = { keyMap = "colemak"; };
  };

  usLayout = {
    x11 = { layout = "us"; };
  };
in
{
  config = mkMerge [
    {
      soxin.settings = {
        keyboard = {
          # ErgoDox has its own way of configuring the layout so long as the
          # software configures it as US layout. In other words, if I configured the
          # keyboard to the Colemak layout and done the same to my OS then the
          # keyboard comes out as an undefined layout (neither Colemak nor US).
          #
          # I tried setting up Colemak being the first layout so it remains the
          # default layout and then add a US layout and for some reason i3 started
          # looking for Mod4+j to move focus left even though in the configuration
          # it's clearly configured as Mod4+n
          #
          # I tried setting up Colemak being the first layout so it remains the
          # default layout and then add a US layout and for some reason i3 started
          # looking for Mod4+j to move focus left even though in the configuration
          # it's clearly configured as Mod4+n.
          #
          # As a workaround, I configured the layouts to be US first then Colemak
          # but override the defaultLayout to Colemak. With this hack the
          # encryption password (early console) and the console remains configured
          # to Colemak but the default layout in i3 is Colemak. I've also configured
          # Right Ctrl + Right Shift to switch between layouts so I can use both of
          # my external and internal keyboards.
          defaultLayout = colemakLayout;
          layouts = [ usLayout colemakLayout ];
        };
        theme = "gruvbox-dark";
      };
    }

    (optionalAttrs (mode == "NixOS") {
      nix = {
        package = pkgs.nixFlakes;

        # enable the sandbox but only on Linux
        useSandbox = pkgs.stdenv.hostPlatform.isLinux;

        extraOptions = ''
          experimental-features = nix-command flakes ca-references
        '';
      };

      boot.tmpOnTmpfs = true;

      security.pki.certificates = [ nasreddineCA ];

      # Set the ssh authorized keys for the root user
      users.users.root = {
        inherit (soxincfg.vars.users.yl) hashedPassword;

        openssh.authorizedKeys.keys = soxincfg.vars.users.yl.sshKeys;
      };

      # set the default locale and the timeZone
      i18n.defaultLocale = "en_US.UTF-8";
      time.timeZone = "America/Los_Angeles";
    })
  ];
}
