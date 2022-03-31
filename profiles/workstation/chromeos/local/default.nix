{ config, home-manager, lib, mode, soxincfg, ... }:

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
    ++ optionals (mode == "NixOS") [ ./nixos.nix ]
    ++ optionals (mode == "home-manager") [ ./home.nix ];

  soxin = {
    hardware = {
      # yubikey.enable = true;
    };

    programs = {
      # keybase = {
      #   enable = true;
      #   enableFs = true;
      # };
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
      # rofi.enable = true;
    };

    services = {
      # caffeine.enable = true;
      # dunst.enable = true;
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
      # openssh.enable = true;
      # printing = {
      #   enable = true;
      #   brands = [ "epson" ];
      # };
      # xserver.enable = true;
    };

    settings = {
      # fonts.enable = true;
      # gtk.enable = true;
    };

    # virtualisation = {
    #   docker.enable = true;
    #   libvirtd.enable = true;
    #   virtualbox.enable = true;
    # };
  };

  soxincfg = {
    programs = {
      # android.enable = true;
      # autorandr.enable = true;
      # brave.enable = true;
      # chromium = { enable = true; surfingkeys.enable = true; };
      dbeaver.enable = true;
      fzf.enable = true;
      git = { enable = true; enableGpgSigningKey = false; };
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
      nix.distributed-builds.enable = true;
    };
  };
}
