inputs@{ self, deploy-rs, ... }:

let
  # the default channel to follow.
  channelName = "nixpkgs";
in
{
  ###
  # x86_64-linux
  ###

  achilles =
    let
      system = "x86_64-linux";
    in
    {
      inherit channelName system;
      modules = [ ./achilles/configuration.nix ];
    };

  hades =
    let
      system = "x86_64-linux";
    in
    {
      inherit channelName system;
      modules = [ ./hades/configuration.nix ];
    };

  x86-64-linux-0 =
    let
      system = "x86_64-linux";
    in
    {
      inherit channelName system;
      modules = [ ./x86-64-linux-0/configuration.nix ];

      deploy = {
        hostname = "x86-64-linux-0.yl.ktdev.io";
        profiles.system = {
          sshUser = "root";
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.x86-64-linux-0;
        };
      };
    };

  zeus =
    let
      system = "x86_64-linux";
    in
    {
      inherit channelName system;
      modules = [ ./zeus/configuration.nix ];

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

  aarch64-linux-0 =
    let
      system = "aarch64-linux";
    in
    {
      inherit channelName system;
      modules = [ ./aarch64-linux-0/configuration.nix ];

      deploy = {
        hostname = "aarch64-linux-0.yl.ktdev.io";
        profiles.system = {
          sshUser = "root";
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.aarch64-linux-0;
        };
      };
    };

  kore =
    let
      system = "aarch64-linux";
    in
    {
      inherit channelName system;
      modules = [ ./kore/configuration.nix ];

      deploy = {
        hostname = "kore.admin.nasreddine.com";
        profiles.system = {
          sshUser = "root";
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.kore;
        };
      };
    };
}
