{
  description = "SoxinCFG by Wael";

  inputs = {
    deploy-rs.url = "github:serokell/deploy-rs";
    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus/v1.5.1";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
    nur.url = "github:nix-community/NUR";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
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

    nixvim = {
      url = "github:kalbasit/nixvim";
      # NOTE: nixvim fails to build on NixOS 24.11
      # inputs. nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:cachix/pre-commit-hooks.nix";
    };

    secret-flake-work = {
      url = "flake:secret-flake-work";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
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

  outputs =
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
      inherit (flake-utils-plus.lib) flattenTree;

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
        profiles = import ./profiles;
        soxin = import ./mysoxin/soxin.nix; # TODO: Get rid of this!
        soxincfg = import ./modules;
      };

      nixosModule = nixosModules.soxincfg;

    in
    soxin.lib.mkFlake {
      inherit
        channels
        channelsConfig
        inputs
        withDeploy
        withSops
        nixosModules
        nixosModule
        ;

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

      outputsBuilder =
        channels:
        let
          pkgs = channels.nixpkgs;
          pre-commit-check = pre-commit-hooks.lib.${pkgs.hostPlatform.system}.run {
            src = ./.;
            hooks = {
              # TODO: Fix all errors and enable statix
              # statix.enable = true;
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
      nixosSpecialArgs = {
        inherit nixos-hardware;
      };

      extraHomeManagerModules = [ "${sops-nix.sourceInfo.outPath}/modules/home-manager/sops.nix" ];
    };
}
