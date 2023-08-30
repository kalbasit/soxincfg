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
        hostname = "hades.wael-nasreddine.gmail.com.beta.tailscale.net";
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
        hostname = "hercules.wael-nasreddine.gmail.com.beta.tailscale.net";
        profiles.system = {
          sshUser = "root";
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.hercules;
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
        hostname = "prometheus.wael-nasreddine.gmail.com.beta.tailscale.net";
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
        hostname = "kore.wael-nasreddine.gmail.com.beta.tailscale.net";
        profiles.system = {
          sshUser = "root";
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.kore;
          confirmTimeout = 5 * 60;
        };
      };
    };
}
