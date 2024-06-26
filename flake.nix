{
  description = "SoxinCFG by Wael";

  inputs = {
    deploy-rs.url = "github:serokell/deploy-rs";
    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus/1.5.0";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.05";
    nur.url = "github:nix-community/NUR";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        nixpkgs-stable.follows = "nixpkgs";
      };
    };

    soxin = {
      url = "github:SoxinOS/soxin";
      inputs = {
        darwin.follows = "darwin";
        deploy-rs.follows = "deploy-rs";
        flake-utils-plus.follows = "flake-utils-plus";
        home-manager.follows = "home-manager";
        nixpkgs-unstable.follows = "nixpkgs-unstable";
        nixpkgs.follows = "nixpkgs";
        nur.follows = "nur";
        sops-nix.follows = "sops-nix";
      };
    };
  };

  outputs = inputs@{ flake-utils-plus, nixos-hardware, nixpkgs, self, sops-nix, soxin, ... }:
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
          patches = [ ./patches/fix-pubkey-lookup.patch ];
        };
      };

      # Default configuration values for `channels.<name>.config = {...}`
      channelsConfig = {
        # allowBroken = true;
        allowUnfree = true;
        # allowUnsupportedSystem = true;

        permittedInsecurePackages = [ ];
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
          "aarch64-darwin"
          "aarch64-linux"
          "x86_64-darwin"
          "x86_64-linux"
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

        extraHomeManagerModules = [
          "${sops-nix.sourceInfo.outPath}/modules/home-manager/sops.nix"
        ];
      };
}
