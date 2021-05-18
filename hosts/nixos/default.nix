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
, ...
}@args:
with lib;
let
  buildHosts = hostPaths:
    builtins.builtins.listToAttrs (
      map (path: nameValuePair (lists.last (splitString "/" path)) (nixosSystem path)) hostPaths
    );

  nixosSystem = path:
    let
      # This allows you to have sub-folders to order cnofigurations inside the
      # hosts folder.
      hostName = lists.last (splitString "/" path);

      flakeModules = builtins.attrValues (removeAttrs self.nixosModules [ "profiles" ]);
    in
    soxin.lib.nixosSystem {
      inherit system;

      globalSpecialArgs = {
        inherit nixos-hardware;
        inherit (pkgset) pkgs-master;
        soxincfg = self;
      };

      globalModules =
        flakeModules
        ++ singleton self.nixosModules.profiles.core;

      nixosModules = [
        # host-specific NixOS configuration
        { networking.hostName = hostName; }

        # include sops module
        sops-nix.nixosModules.sops

        # include the local configuration for the host
        "${path}/configuration.nix"

        # setup Nix
        {
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

          nixpkgs = {
            inherit (pkgset) pkgs;
            overlays = [ nur.overlay soxin.overlay self.overlay self.overrides.${system} ];
          };

          nix.registry = {
            nixpkgs.flake = nixpkgs;
            nixpkgs-master.flake = nixpkgs-master;
            soxincfg.flake = self;
          };

          system.configurationRevision = mkIf (self ? rev) self.rev;
        }
      ];
    };
in
if system == "x86_64-linux" then
  import ./x86-64 { inherit buildHosts; }
else if system == "aarch64-linux" then
  import ./aarch64-linux { inherit buildHosts; }
else builtins.trace "I don't have any hosts buildable for the system ${system}" [ ]
