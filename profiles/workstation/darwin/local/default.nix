{ config, home-manager, lib, mode, pkgs, soxincfg, ... }:

let
  inherit (lib)
    optionals
    ;

  inherit (home-manager.lib.hm.dag)
    entryBefore
    entryAnywhere
    ;
in
{
  imports =
    [ soxincfg.nixosModules.profiles.workstation.common ]
    ++ optionals (mode == "nix-darwin") [ ./nix-darwin.nix ]
    ++ optionals (mode == "home-manager") [ ./home.nix ];


  soxin = {
    # hardware = {
    #   fwupd.enable = true;
    #   sound.enable = true;
    #   yubikey.enable = true;
    # };

    programs = {
      less.enable = true;
      # rbrowser = {
      #   enable = true;
      #   setMimeList = true;
      #   browsers = {
      #     "firefox@personal" = home-manager.lib.hm.dag.entryBefore [ "brave@personal" ] { };
      #     "brave@personal" = home-manager.lib.hm.dag.entryBefore [ "firefox@private" ] { };
      #     "firefox@private" = home-manager.lib.hm.dag.entryBefore [ "firefox@anya" ] { };
      #     "firefox@anya" = home-manager.lib.hm.dag.entryBefore [ "firefox@vanya" ] { };
      #     "firefox@vanya" = home-manager.lib.hm.dag.entryBefore [ "firefox@tanya" ] { };
      #     "firefox@tanya" = home-manager.lib.hm.dag.entryBefore [ "firefox@ihab" ] { };
      #     "firefox@ihab" = home-manager.lib.hm.dag.entryAnywhere { };
      #   };
      # };
      # rofi = {
      #   enable = true;
      #   i3.enable = true;
      # };
    };

    services = {
      # TODO: this should be a catenate service
      # caffeine.enable = true;
      # dunst.enable = true;
      # TODO: this does not work on Mac because of systemd things
      # gpgAgent.enable = true;
      # locker = {
      #   enable = true;
      #   color = "ffa500";
      #   extraArgs = [
      #     "--clock"
      #     "--show-failed-attempts"
      #     "--datestr='%A %Y-%m-%d'"
      #   ];
      # };
      # networkmanager.enable = true;
      openssh.enable = true;
      printing = {
        enable = true;
        brands = [ "epson" ];
      };
      # xserver.enable = true;
    };

    virtualisation = {
      docker.enable = true;
      libvirtd.enable = true;
      virtualbox.enable = true;
    };
  };

  soxincfg = {
    programs = {
      android.enable = true;
      # brave.enable = true;
      # chromium = { enable = true; surfingkeys.enable = true; };
      # dbeaver.enable = true;
      fzf.enable = true;
      git.enable = true;
      mosh.enable = true;
      neovim.enable = true;
      pet.enable = true;
      ssh.enable = true;
      starship.enable = true;
      # termite.enable = true;
      tmux.enable = true;
      zsh.enable = true;
    };

    # services = {
    #   xserver.windowManager.i3.enable = true;
    # };

    settings = {
      fonts.enable = true;
      # gtk.enable = true;
      nix.distributed-builds.enable = true;
    };
  };
}

