{
  description = "SoxinCFG by Wael";

  inputs = {
    # Claude Code, packaged from Anthropic's release binaries and updated
    # within hours of each release, ahead of nixpkgs.
    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    deploy-rs.url = "github:serokell/deploy-rs";
    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus/v1.5.1";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    # nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/release-26.05";
    nur.url = "github:nix-community/NUR";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/release-26.05";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    nixvim = {
      url = "github:kalbasit/nixvim";
      # XXX: Leave nixvim with its own tested nixpkgs.
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    # Soxin v2: Soxin's layer on Clan. Local while v2 is unpublished.
    soxin = {
      url = "github:SoxinOS/soxin/v2";
      inputs = {
        home-manager.follows = "home-manager";
        nix-darwin.follows = "darwin";
        nixpkgs.follows = "nixpkgs";
        sops-nix.follows = "sops-nix";
      };
    };
  };

  # soxincfg defines no machines: a fleet's own flake calls `lib.mkFlake`
  # with its hosts (see lib/mk-flake.nix). This flake builds an empty fleet,
  # for its checks, development shell, formatter and packages.
  outputs =
    inputs:
    let
      mkFlake = import ./lib/mk-flake.nix inputs;

      supportedSystems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
    in
    {
      lib = {
        inherit mkFlake;

        # The library Soxin v1's modules (`<kind>Modules.soxinv1`) take as
        # their `soxinLib` argument.
        soxinLib = import ./soxinv1/lib inputs;
      };
    }
    // (mkFlake {
      home-managers = { };
      hosts = { };
      inherit supportedSystems;
    });
}
