{
  description = "SoxinCFG by Wael";

  inputs = {
    deploy-rs.url = "github:serokell/deploy-rs";
    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus/v1.5.1";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs";
    nur.url = "github:nix-community/NUR";

    home-manager = {
      url = "github:nix-community/home-manager";
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
    inputs:
    let
      home-managers = import ./home-managers inputs;

      hosts = import ./hosts inputs;

      mkFlake = import ./lib/mk-flake.nix inputs;

      supportedSystems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
    in
    {
      lib = { inherit mkFlake; };
    }
    // (mkFlake {
      inherit
        home-managers
        hosts
        supportedSystems
        ;
    });
}
