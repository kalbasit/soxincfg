{
  description = "SoxinCFG by Wael";

  inputs = {
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

    # The diwan monorepo: the Nazir host agent (nazir-agent) that machines
    # running fleet work install, maktab (the
    # workspace manager, with its plugins) and majlis (what workers report
    # with). Not the control plane, which runs elsewhere; the MCP servers are
    # wired by whichever configuration runs the assistant.
    #
    # Over ssh: the repository is private and lives on the forge's own host,
    # so there is no anonymous shorthand that could fetch it.
    #
    # No `follows` on nixpkgs: everything taken from it builds against the
    # nixpkgs diwan's own flake locks, which is the build diwan tests.
    diwan.url = "git+ssh://git@git.nasreddine.com/diwan/diwan.git";
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
