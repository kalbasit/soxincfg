{
  channelName,
  deploy-rs,
  self,
}:

{
  pve-nixos-25-05 =
    let
      system = "x86_64-linux";
    in
    {
      inherit channelName system;
      modules = [ ./nixos-25.05/nixos.nix ];

      deploy = {
        hostname = "192.168.150.6";
        profiles.system = {
          sshUser = "root";
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.pve-nixos-25-05;
        };
      };
    };

  pve-tailscale2 =
    let
      system = "x86_64-linux";
    in
    {
      inherit channelName system;
      modules = [ ./tailscale2/nixos.nix ];

      deploy = {
        hostname = "192.168.100.10";
        profiles.system = {
          sshUser = "root";
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.pve-tailscale2;
        };
      };
    };
}
