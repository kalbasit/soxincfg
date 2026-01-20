{ soxincfg }:
{
  config,
  lib,
  ...
}:

let
  homePath = config.home.homeDirectory;
in
{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.personal
    soxincfg.nixosModules.profiles.neovim.full
    soxincfg.nixosModules.profiles.workstation.darwin.local
  ];

  soxincfg = {
    # TODO: Move to the darwin workstation profile
    programs.secretive.enable = true;
    services.ssh-agent-mux.enable = true;
  };

  home.stateVersion = "24.11";

  sops = {
    age.keyFile = "${homePath}/Library/Application Support/sops/age/keys.txt";
  };

  ## TODO: https://gemini.google.com/share/bd0793bd1ba3

  launchd.agents = {
    # 1. Fix sops-nix: Force retry on crash/failure
    sops-nix = {
      config = {
        # This is the magic sauce
        KeepAlive = lib.mkForce {
          Crashed = true;
          SuccessfulExit = false;
        };
        # Give it a breather between attempts so it doesn't spin-loop
        ThrottleInterval = 5;
      };
    };

    # 2. Fix yabai: Wait for GUI
    yabai = {
      config = {
        KeepAlive = lib.mkForce {
          Crashed = true;
          SuccessfulExit = false;
        };
      };
    };

    # 3. Fix skhd: Wait for GUI
    skhd = {
      config = {
        KeepAlive = lib.mkForce {
          Crashed = true;
          SuccessfulExit = false;
        };
      };
    };
  };
  ## END TODO
}
