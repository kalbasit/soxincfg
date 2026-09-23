# home-manager configuration for user `wnasreddine`
{ soxincfg }:

{
  imports = [
    soxincfg.nixosModules.profiles.wsl-gaming
  ];

  # This machine joins the steward fleet. It is a WSL instance on a desktop
  # that reboots for Windows, so it is `intermittent` rather than `sleeps`:
  # it does not suspend and come back on a schedule anyone can predict, it is
  # simply there or it is not, and the scheduler should treat it that way.
  soxincfg.programs.steward = {
    enable = true;
    url = "https://steward.prod.nasreddine.com";

    # Not in the nix store and not in this repository. See the module's
    # credentialsFile description for why the token has no option of its own.
    # sops-nix on NixOS decrypts to /run/secrets/<name>. Written out rather
    # than read from config.sops, because this is the home-manager tree and the
    # secret is declared in the NixOS one.
    credentialsFile = "/run/secrets/steward_env";

    reliability = "intermittent";
    labels = {
      os = "linux";
      platform = "nixos";
    };
  };

  home.stateVersion = "26.05";
}
