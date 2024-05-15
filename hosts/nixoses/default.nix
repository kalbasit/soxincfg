inputs@{ self, deploy-rs, lib ? nixpkgs.lib, nixpkgs, ... }:

let
  inherit (lib)
    mapAttrs
    recursiveUpdate
    ;

  # the default channel to follow.
  channelName = "nixpkgs";

  # the operating mode of Soxin
  mode = "NixOS";
in
mapAttrs
  (n: v: recursiveUpdate
  {
    inherit
      mode
      ;
  }
    v)
{
  ###
  # x86_64-linux
  ###

  hades =
    let
      system = "x86_64-linux";
    in
    {
      inherit channelName system;
      modules = [ ./hades/nixos.nix ];

      deploy = {
        hostname = "hades.bigeye-bushi.ts.net";
        profiles.system = {
          sshUser = "root";
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.hades;
        };
      };
    };

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

  laptop-server-x86-1 =
    let
      system = "x86_64-linux";
    in
    {
      inherit channelName system;
      modules = [ ./laptop-cluster/laptop-server-x86-1/nixos.nix ];

      deploy = {
        hostname = "laptop-server-x86-1.bigeye-bushi.ts.net";
        profiles.system = {
          sshUser = "root";
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.laptop-server-x86-1;
        };
      };
    };

  laptop-server-x86-2 =
    let
      system = "x86_64-linux";
    in
    {
      inherit channelName system;
      modules = [ ./laptop-cluster/laptop-server-x86-2/nixos.nix ];

      deploy = {
        hostname = "laptop-server-x86-2.bigeye-bushi.ts.net";
        profiles.system = {
          sshUser = "root";
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.laptop-server-x86-2;
        };
      };
    };

  laptop-server-x86-3 =
    let
      system = "x86_64-linux";
    in
    {
      inherit channelName system;
      modules = [ ./laptop-cluster/laptop-server-x86-3/nixos.nix ];

      deploy = {
        hostname = "laptop-server-x86-3.bigeye-bushi.ts.net";
        profiles.system = {
          sshUser = "root";
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.laptop-server-x86-3;
        };
      };
    };

  laptop-server-x86-4 =
    let
      system = "x86_64-linux";
    in
    {
      inherit channelName system;
      modules = [ ./laptop-cluster/laptop-server-x86-4/nixos.nix ];

      deploy = {
        hostname = "192.168.10.131";
        profiles.system = {
          sshUser = "root";
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.laptop-server-x86-4;
        };
      };
    };

  prometheus =
    let
      system = "x86_64-linux";
    in
    {
      inherit channelName system;
      modules = [ ./prometheus/nixos.nix ];

      deploy = {
        hostname = "prometheus.bigeye-bushi.ts.net";
        profiles.system = {
          sshUser = "root";
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.prometheus;
        };
      };
    };

  zeus =
    let
      system = "x86_64-linux";
    in
    {
      inherit channelName system;
      modules = [ ./zeus/nixos.nix ];

      deploy = {
        hostname = "zeus.admin.nasreddine.com";
        profiles.system = {
          sshUser = "root";
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.zeus;
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
}
