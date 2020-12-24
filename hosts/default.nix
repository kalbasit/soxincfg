{ deploy-rs
, futils
, home-manager
, lib
, nixos-hardware
, nixpkgs
, nixpkgs-master
, nur
, pkgset
, self
, sops-nix
, soxin
, system
}:
let
  config = path:
    let
      # This allows you to have sub-folders to order cnofigurations inside the
      # hosts folder.
      hostName = lib.lists.last (lib.splitString "/" path);
    in
    soxin.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit nixos-hardware;
        inherit (pkgset) nixpkgs-master;
        soxincfg = self;
      };

      modules =
        let
          inherit (self.nixosModules.profiles) core;

          global = {
            networking.hostName = hostName;
            nix.nixPath =
              let
                path = toString ../.;
              in
              [
                "nixpkgs=${nixpkgs}"
                "nixpkgs-master=${nixpkgs-master}"

                # TODO: overlays are not working. Marc will propose a different approach.
                # "nixpkgs-overlays=${path}/overlays"
              ];

            nixpkgs = { pkgs = pkgset.nixpkgs; };

            nix.registry = {
              nixpkgs.flake = nixpkgs;
              nixpkgs-master.flake = nixpkgs-master;
              soxincfg.flake = self;
            };

            system.configurationRevision = lib.mkIf (self ? rev) self.rev;
          };

          overrides = {
            nixpkgs.overlays =
              let
                override = import ../pkgs/override.nix pkgset.nixpkgs-master;

                overlay = pkg: _: _: {
                  "${pkg.pname}" = pkg;
                };
              in
              lib.concat [ nur.overlay soxin.overlay ] (map overlay override);
          };

          local = import "${toString ./.}/${path}/configuration.nix";

          flakeModules = builtins.attrValues (removeAttrs self.nixosModules [ "profiles" ]);

        in
        lib.concat flakeModules [
          core
          global
          overrides
          local

          sops-nix.nixosModules.sops

          # This allows us to use our flake modules in NixOS and home-manager
          # configurations.
          {
            options.home-manager.users = lib.mkOption {
              type = lib.types.attrsOf (lib.types.submoduleWith { modules = flakeModules; });
            };
          }
        ];
    };

  hosts =
    if system == "x86_64-linux" then
      lib.genAttrs [ "achilles" "hades" "zeus" ] config
    else if system == "aarch64-linux" then
      lib.genAttrs [ "aarch64-linux-0" "kore" ] config
    else throw "I don't have any hosts buildable for the system ${system}";
in
hosts
