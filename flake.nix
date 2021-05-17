{
  description = "Soxin template flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/4a9b0f0eb450d7bef5db5c05c2086b24aaecf05c";
    nixpkgs-master.url = "github:NixOS/nixpkgs/4a9b0f0eb450d7bef5db5c05c2086b24aaecf05c";
    home-manager = {
      url = "github:nix-community/home-manager/77188bcd6e2c6c7a99253b36f08ed7b65f2901d2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    soxin = {
      url = "github:SoxinOS/soxin/personal/soxin/home-manager-standalone";
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

  outputs =
    { self
    , deploy-rs
    , futils
    , home-manager
    , nixpkgs
    , nixpkgs-master
    , nur
    , sops-nix
    , soxin
    , ...
    } @ inputs:
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
          homeConfigurations.penguin = soxin.lib.homeManagerConfiguration rec{
            system = "x86_64-linux";
            homeDirectory = "/home/yl";
            username = "yl";
            configuration = ./hosts/penguin/home.nix;
            hmSpecialArgs = { soxincfg = self; };
            inherit (pkgset system) pkgs;
            modules =
              let
                flakeModules = builtins.attrValues (removeAttrs self.nixosModules [ "profiles" ]);
              in
              lib.concat flakeModules [
                self.nixosModules.profiles.core
                { nixpkgs.overlays = [ nur.overlay soxin.overlay self.overlay self.overrides.${system} ]; }
              ];
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

          nixosModules = {
            profiles = import ./profiles;
            soxin = import ./soxin/soxin.nix;
            soxincfg = import ./modules/soxincfg.nix;
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
              (home-manager.packages.${system}.home-manager)
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
