{ mode, lib, ... }:

with lib;

mkMerge [
  {
    soxin = {
      hardware = {
        bluetooth.enable = true;
        fwupd.enable = true;
        sound.enable = true;
        yubikey.enable = true;
      };

      programs = {
        autorandr.enable = true;
        fzf.enable = true;
        git.enable = true;
        htop.enable = true;
        keybase.enable = true;
        mosh.enable = true;
        neovim.enable = true;
        ssh.enable = true;
        tmux.enable = true;
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

      virtualisation = {
        docker.enable = true;
        libvirtd.enable = true;
        # virtualbox is currently marked as broken upstream with kernel > 5.9
        # virtualbox.enable = true;
      };
    };

    soxincfg = {
      programs = {
        brave.enable = true;
        chromium = { enable = true; surfingkeys.enable = true; };
        git.enable = true;
        starship.enable = true;
      };

      services = {
        xserver.windowManager.i3.enable = true;
      };
    };
  }

  (optionalAttrs (mode == "NixOS") {
    environment.homeBinInPath = true;

    services.gnome3.gnome-keyring.enable = true;

    services.logind = {
      lidSwitch = "hybrid-sleep";
      lidSwitchDocked = "ignore";
      lidSwitchExternalPower = "hybrid-sleep";
      extraConfig = ''
        HandlePowerKey=suspend
      '';
    };

    # Redshift
    location.latitude = 34.42;
    location.longitude = -122.11;
    services.redshift = {
      brightness.day = "1.0";
      brightness.night = "0.6";
      enable = true;
      temperature.day = 5900;
      temperature.night = 3700;
    };

    # TODO: fix this!
    system.extraSystemBuilderCmds = ''ln -sfn /yl/.surfingkeys.js $out/.surfingkeys.js'';

    # L2TP VPN does not connect without the presence of this file!
    # https://github.com/NixOS/nixpkgs/issues/64965
    system.activationScripts.ipsec-secrets = ''
      touch $out/etc/ipsec.secrets
    '';
  })
]
