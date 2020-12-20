{
  description = "Soxin template flake";

  inputs = {
    nixos.url = "nixpkgs/nixos-20.09";
    master.url = "nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-20.09";
      inputs.nixpkgs.follows = "nixos";
    };
    soxin = {
      url = "github:SoxinOS/soxin";
      inputs = {
        nixpkgs.follows = "nixos";
        home-manager.follows = "home-manager";
      };
    };
    futils.url = "github:numtide/flake-utils";
    nixos-hardware.url = "nixos-hardware";
    nur.url = "nur";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixos, master, soxin, futils, sops-nix, ... } @ inputs:
    let
      inherit (nixos) lib;
      inherit (nixos.lib) recursiveUpdate;
      inherit (futils.lib) eachDefaultSystem;

      pkgImport = pkgs: system:
        import pkgs {
          inherit system;
          overlays = lib.attrValues self.overlays;
          config = { allowUnfree = true; };
        };

      pkgset = system: {
        nixos = pkgImport nixos system;
        master = pkgImport master system;
      };

      multiSystemOutputs = eachDefaultSystem (system:
        let
          pkgset' = pkgset system;
          osPkgs = pkgset'.nixos;
          pkgs = pkgset'.master;
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
              git
              sops
              sops-nix.packages.${system}.ssh-to-pgp
              nixpkgs-fmt
              pre-commit
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
      };
    in
    recursiveUpdate multiSystemOutputs outputs;
}
