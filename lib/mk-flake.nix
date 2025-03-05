inputs@{
  flake-utils-plus,
  nixos-hardware,
  nixpkgs,
  pre-commit-hooks,
  self,
  sops-nix,
  soxin,
  ...
}:
let
  inherit (flake-utils-plus.lib)
    flattenTree
    ;

  inherit (nixpkgs.lib)
    recursiveUpdate
    ;

  # Enable deploy-rs support
  withDeploy = true;

  # Enable sops support
  withSops = true;

  # Channel definitions. `channels.<name>.{input,overlaysBuilder,config,patches}`
  channels = {
    nixpkgs = {
      # Channel specific overlays
      overlaysBuilder = channels: [
        (_: super: {
          inherit (channels.nixpkgs-unstable)
            # inherit packages from unstable.
            debootstrap
            devbox
            protonvpn-gui
            ;
        })
      ];

      # Channel specific configuration. Overwrites `channelsConfig` argument
      config = {
        permittedInsecurePackages = [ ];
      };

      # Yep, you see it first folks - you can patch nixpkgs!
      patches = [ ];
    };
  };

  # Default configuration values for `channels.<name>.config = {...}`
  channelsConfig = {
    # allowBroken = true;
    allowUnfree = true;
    # allowUnsupportedSystem = true;

    permittedInsecurePackages = [ ];
  };

  nixosModules = {
    profiles = import ../profiles;
    soxin = import ../mysoxin/soxin.nix; # TODO: Get rid of this!
    soxincfg = import ../modules;
  };

  nixosModule = nixosModules.soxincfg;

in

{
  home-managers,
  hosts,
  supportedSystems,
  vars ? { },
}:
soxin.lib.mkFlake {
  inherit
    channels
    channelsConfig
    home-managers
    hosts
    inputs
    withDeploy
    withSops
    nixosModules
    nixosModule
    supportedSystems
    ;

  # add Soxin's main module to all builders
  extraGlobalModules = [
    nixosModule
    nixosModules.profiles.core

    # import mysoxin
    # TODO: Get rid of this!
    nixosModules.soxin
  ];

  outputsBuilder =
    channels:
    let
      pkgs = channels.nixpkgs;
      pre-commit-check = pre-commit-hooks.lib.${pkgs.hostPlatform.system}.run {
        src = ../.;
        hooks = {
          statix.enable = true;
          nixfmt-rfc-style.enable = true;
        };
      };
    in
    {
      checks = {
        inherit pre-commit-check;
      };

      devShell =
        with pkgs;
        mkShell {
          inherit (pre-commit-check) shellHook;
          buildInputs = [
            nixfmt-rfc-style
            nix-output-monitor
          ];
        };

      formatter = pkgs.nixfmt-rfc-style;
    };

  # Evaluates to `packages.<system>.<pname> = <unstable-channel-reference>.<pname>`.
  packagesBuilder = channels: flattenTree (import ../pkgs channels);

  vars = recursiveUpdate (import ../vars inputs) vars;

  # include all overlays
  overlay = import ../overlays;

  # set the nixos specialArgs
  nixosSpecialArgs = {
    inherit nixos-hardware;
  };

  extraHomeManagerModules = [ "${sops-nix.sourceInfo.outPath}/modules/home-manager/sops.nix" ];
}
