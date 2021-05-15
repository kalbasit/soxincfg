{
  description = "Soxin template flake";

  inputs = {
    nixpkgs.url = "nixpkgs/master";
    nixpkgs-master.url = "nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-master = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-master";
    };
    soxin = {
      url = "github:SoxinOS/soxin";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    futils.url = "github:numtide/flake-utils";
    nixos-hardware.url = "nixos-hardware";
    nur.url = "nur";
    sops-nix.url = "github:Mic92/sops-nix";
    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs = { self, home-manager-master, nixpkgs, nixpkgs-master, soxin, futils, sops-nix, deploy-rs, ... } @ inputs:
    let
      inherit (nixpkgs) lib;
      inherit (nixpkgs.lib) recursiveUpdate;
      inherit (futils.lib) eachDefaultSystem;

      pkgset = system:
        let
          config = { allowUnfree = true; };
          overlays = lib.concat (lib.attrValues self.overlays) [ self.overrides.${system} ];
        in
        {
          pkgs = import nixpkgs { inherit config overlays system; };
          pkgs-master = import nixpkgs-master {
            inherit config system;
            overlays = lib.attrValues self.overlays;
          };
        };

      anySystemOutputs =
        let
          overlays = import ./overlays;
          overlay = overlays.packages;
        in
        {
          inherit overlay overlays;

          checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

          deploy.nodes = {
            aarch64-linux-0 = {
              hostname = "aarch64-linux-0.yl.ktdev.io";
              profiles.system = {
                sshUser = "root";
                user = "root";
                path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.aarch64-linux-0;
              };
            };

            kore = {
              hostname = "kore.admin.nasreddine.com";
              profiles.system = {
                sshUser = "root";
                user = "root";
                path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.kore;
              };
            };

            x86-64-linux-0 = {
              hostname = "x86-64-linux-0.yl.ktdev.io";
              profiles.system = {
                sshUser = "root";
                user = "root";
                path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.x86-64-linux-0;
              };
            };

            zeus = {
              hostname = "zeus.admin.nasreddine.com";
              profiles.system = {
                sshUser = "root";
                user = "root";
                path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.zeus;
              };
            };
          };

          # TODO: deliver this similarly to nixosConfigurations
          homeConfigurations.penguin = soxin.lib.homeManagerConfiguration {
            system = "x86_64-linux";
            homeDirectory = "/home/yl";
            username = "yl";
            configuration = ./hosts/penguin/home.nix;
            hmSpecialArgs = { soxincfg = self; };
          };

          nixosConfigurations =
            let
              hostsForSystem = system:
                import ./hosts (
                  recursiveUpdate inputs {
                    inherit lib system;
                    pkgset = pkgset system;
                  }
                );
            in
            (hostsForSystem "x86_64-linux")
            //
            (hostsForSystem "aarch64-linux");

          nixosModules = recursiveUpdate (import ./modules) {
            profiles = import ./profiles;
            soxin = import ./soxin/soxin.nix;
          };

          vars = import ./vars;
        };

      multiSystemOutputs = eachDefaultSystem (system:
        let
          inherit (pkgset system) pkgs pkgs-master;
        in
        {
          devShell = pkgs.mkShell {
            sopsPGPKeyDirs = [
              "./vars/sops-keys/hosts"
              "./vars/sops-keys/users"
            ];

            nativeBuildInputs = [
              sops-nix.packages.${system}.sops-pgp-hook
            ];

            buildInputs = with pkgs; [
	      (home-manager-master.packages.${system}.home-manager)
              awscli
              deploy-rs.packages.${system}.deploy-rs
              git
              gnumake
              nixpkgs-fmt
              pre-commit
              sops
              sops-nix.packages.${system}.ssh-to-pgp

              (terraform.withPlugins (ps: [
                ps.aws
                ps.secret
                ps.unifi
              ]))
            ];

            shellHook = ''
              sopsPGPHook
              git config diff.sopsdiffer.textconv "sops -d"
            '';
          };

          overrides = import ./overlays/overrides.nix pkgs-master;

          packages = soxin.lib.overlaysToPkgs { inherit (self.overlays) packages; } pkgs;
        });
    in
    recursiveUpdate multiSystemOutputs anySystemOutputs;
}
