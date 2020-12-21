{
  description = "Soxin template flake";

  inputs = {
    nixpkgs.url = "nixpkgs/release-20.09";
    nixpkgs-master.url = "nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-20.09";
      inputs.nixpkgs.follows = "nixpkgs";
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
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-master, soxin, futils, sops-nix, deploy-rs, ... } @ inputs:
    let
      inherit (nixpkgs) lib;
      inherit (nixpkgs.lib) recursiveUpdate;
      inherit (futils.lib) eachDefaultSystem;

      pkgImport = pkgs: system:
        import pkgs {
          inherit system;
          overlays = lib.attrValues self.overlays;
          config = { allowUnfree = true; };
        };

      pkgset = system: {
        nixpkgs = pkgImport nixpkgs system;
        nixpkgs-master = pkgImport nixpkgs-master system;
      };

      multiSystemOutputs = eachDefaultSystem (system:
        let
          pkgset' = pkgset system;
          osPkgs = pkgset'.nixpkgs;
          pkgs = pkgset'.nixpkgs-master;
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
              deploy-rs.packages.${system}.deploy-rs
              git
              nixpkgs-fmt
              pre-commit
              sops
              sops-nix.packages.${system}.ssh-to-pgp
            ];

            shellHook = ''
              sopsPGPHook
              git config diff.sopsdiffer.textconv "sops -d"
            '';
          };

          packages = soxin.lib.overlaysToPkgs self.overlays pkgs;
        }
      );

      outputs = {
        overlay = self.overlays.packages;

        vars = import ./vars;

        overlays = import ./overlays;

        nixosModules = recursiveUpdate (import ./modules) {
          profiles = import ./profiles;
          soxin = import ./soxin/soxin.nix;
          # TODO: Do I need this?
          # soxincfg = import ./modules/soxincfg.nix;
        };

        nixosConfigurations =
          let
            system = "x86_64-linux";
            pkgset' = pkgset system;
          in
          import ./hosts (
            recursiveUpdate inputs {
              inherit lib system;
              pkgset = pkgset';
            }
          );

        deploy.nodes = {
          zeus = {
            hostname = "zeus.admin.nasreddine.com";
            profiles.system = {
              sshUser = "root";
              user = "root";
              path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.zeus;
            };
          };
        };

        checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
      };
    in
    recursiveUpdate multiSystemOutputs outputs;
}
