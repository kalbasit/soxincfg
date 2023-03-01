{
  description = "SoxinCFG by Wael";

  inputs = {
    deploy-rs.url = "github:serokell/deploy-rs";
    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    # nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/master";
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.11";
    nur.url = "github:nix-community/NUR";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    soxin = {
      url = "github:SoxinOS/soxin";
      inputs = {
        deploy-rs.follows = "deploy-rs";
        flake-utils-plus.follows = "flake-utils-plus";
        home-manager.follows = "home-manager";
        nixpkgs-unstable.follows = "nixpkgs-unstable";
        nixpkgs.follows = "nixpkgs";
        nur.follows = "nur";
      };
    };
  };

  outputs = inputs@{ flake-utils-plus, nixos-hardware, nixpkgs, self, soxin, ... }:
    let
      # Enable deploy-rs support
      withDeploy = true;

      # Enable sops support
      withSops = true;

      inherit (nixpkgs) lib;
      inherit (lib) optionalAttrs recursiveUpdate singleton;
      inherit (flake-utils-plus.lib) flattenTree;

      # Channel definitions. `channels.<name>.{input,overlaysBuilder,config,patches}`
      channels = {
        nixpkgs = {
          # Channel specific overlays
          overlaysBuilder = channels: [
            (_: super: {
              inherit (channels.nixpkgs-unstable)
                # inherit packages from unstable.
                ;
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
        # allowUnsupportedSystem = true;
      };

      nixosModules = (import ./modules) // {
        soxin = import ./mysoxin/soxin.nix; # TODO: Get rid of this!
        soxincfg = import ./modules/soxincfg.nix;
        profiles = import ./profiles;
      };

      nixosModule = nixosModules.soxincfg;

    in
    soxin.lib.mkFlake
      {
        inherit channels channelsConfig inputs withDeploy withSops nixosModules nixosModule;

        # add Soxin's main module to all builders
        extraGlobalModules = [
          nixosModule
          nixosModules.profiles.core

          # import mysoxin
          # TODO: Get rid of this!
          nixosModules.soxin
        ];

        # Supported systems, used for packages, apps, devShell and multiple other definitions. Defaults to `flake-utils.lib.defaultSystems`
        supportedSystems = [
          "aarch64-linux"
          "x86_64-linux"
          "x86_64-darwin"
        ];

        devShellBuilder = channels: with channels.nixpkgs; mkShell {
          buildInputs = [ arion ];
        };

        # pull in all hosts
        hosts = import ./hosts inputs;

        # create all home-managers
        home-managers = import ./home-managers inputs;

        # Evaluates to `packages.<system>.<pname> = <unstable-channel-reference>.<pname>`.
        packagesBuilder = channels: flattenTree (import ./pkgs channels);

        # declare the vars
        vars = import ./vars inputs;

        # include all overlays
        overlay = import ./overlays;

        # set the nixos specialArgs
        nixosSpecialArgs = { inherit nixos-hardware; };
      };
}
