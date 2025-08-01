{
  self,
  deploy-rs,
  lib ? nixpkgs.lib,
  nixpkgs,
  ...
}:

let
  inherit (lib) mapAttrs recursiveUpdate;

  # the default channel to follow.
  channelName = "nixpkgs";

  # the operating mode of Soxin
  mode = "NixOS";

  # the hostType of the installation
  hostType = "NixOS";

  hosts = {
    ###
    # x86_64-linux
    ###

    hercules =
      let
        system = "x86_64-linux";
      in
      {
        inherit channelName system;
        modules = [ ./hercules/nixos.nix ];

        deploy = {
          hostname = "hercules.bigeye-bushi.ts.net";
          profiles.system = {
            sshUser = "root";
            user = "root";
            path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.hercules;
          };
        };
      };

    ###
    # aarch64-linux
    ###

    kore =
      let
        system = "aarch64-linux";
      in
      {
        inherit channelName system;
        modules = [ ./kore/nixos.nix ];

        deploy = {
          hostname = "kore.bigeye-bushi.ts.net";
          profiles.system = {
            sshUser = "root";
            user = "root";
            path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.kore;
            confirmTimeout = 5 * 60;
          };
        };
      };

    saturn-nixos-vm =
      let
        system = "aarch64-linux";
      in
      {
        inherit channelName system;
        modules = [ ./saturn-nixos-vm/nixos.nix ];
      };
  };

  pve-hosts = import ./pve { inherit channelName deploy-rs self; };

  createHostMapFn =
    n: v:
    recursiveUpdate {
      inherit mode;

      specialArgs = {
        inherit hostType;
      };
    } v;
in
mapAttrs createHostMapFn (hosts // pve-hosts)
