{
  description = "SoxinCFG by Wael";

  inputs = {
    deploy-rs.url = github:serokell/deploy-rs;
    nixos-hardware.url = github:NixOS/nixos-hardware;
    nixpkgs.url = github:NixOS/nixpkgs/7d71001b796340b219d1bfa8552c81995017544a;
    nur.url = github:nix-community/NUR;
    unstable.url = github:NixOS/nixpkgs/nixos-unstable;
    utils.url = github:gytis-ivaskevicius/flake-utils-plus/v1.1.0;

    soxin = {
      url = github:SoxinOS/soxin;
      inputs = {
        deploy-rs.follows = "deploy-rs";
        nixpkgs.follows = "nixpkgs";
        nur.follows = "nur";
        unstable.follows = "unstable";
        utils.follows = "utils";
      };
    };
  };

  outputs = inputs@{ nixos-hardware, nixpkgs, self, soxin, utils, ... }:
    let
      # Enable deploy-rs support
      withDeploy = true;

      # Enable sops support
      withSops = true;

      inherit (nixpkgs) lib;
      inherit (lib) optionalAttrs recursiveUpdate singleton;
      inherit (utils.lib) flattenTree;

      # Channel definitions. `channels.<name>.{input,overlaysBuilder,config,patches}`
      channels = {
        nixpkgs = {
          # Channel specific overlays
          overlaysBuilder = channels: [
            (final: prev: {
              jetbrains = channels.unstable.jetbrains // {
                idea-ultimate = channels.unstable.jetbrains.idea-ultimate.overrideAttrs (oa: rec {
                  name = "idea-ultimate-${version}";
                  version = "2020.2.4";
                  src = prev.fetchurl {
                    url = "https://download.jetbrains.com/idea/ideaIU-${version}-no-jbr.tar.gz";
                    sha256 = "sha256-/pYbEN7vExfgXEuQy+Sc97h2HzxPlJ3im7VjraJEGRc=";
                  };
                });
              };
            })
          ];

          # Channel specific configuration. Overwrites `channelsConfig` argument
          config = { };

          # Yep, you see it first folks - you can patch nixpkgs!
          patches = [ ];
        };
      };

      # Default configuration values for `channels.<name>.config = {...}`
      channelsConfig = {
        # allowBroken = true;
        allowUnfree = true;
      };

      nixosModules = (import ./modules) // {
        soxincfg = import ./modules/soxincfg.nix;
        profiles = import ./profiles;
      };

      nixosModule = nixosModules.soxincfg;

    in
    soxin.lib.systemFlake {
      inherit inputs withDeploy withSops nixosModules nixosModule;

      # add Soxin's main module to all builders
      extraGlobalModules = [ nixosModule nixosModules.profiles.core ];

      # Supported systems, used for packages, apps, devShell and multiple other definitions. Defaults to `flake-utils.lib.defaultSystems`
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" ];

      # pull in all hosts
      hosts = import ./hosts inputs;

      # create all home-managers
      home-managers = import ./home-managers inputs;

      # Evaluates to `packages.<system>.<pname> = <unstable-channel-reference>.<pname>`.
      packagesBuilder = channels: flattenTree (import ./pkgs channels);

      # declare the vars that are used only by sops
      vars = optionalAttrs withSops (import ./vars inputs);

      # include all overlays
      overlay = import ./overlays;

      # set the nixos specialArgs
      nixosSpecialArgs = { inherit nixos-hardware; };
    };
}
