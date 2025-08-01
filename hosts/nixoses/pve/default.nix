{
  channelName,
  deploy-rs,
  self,
}:

{
  # TEMPLATE
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

  pve-basicdns0 =
    let
      system = "x86_64-linux";
    in
    {
      inherit channelName system;
      modules = [ ./basicdns0/nixos.nix ];

      deploy = {
        hostname = "192.168.20.10";
        profiles.system = {
          sshUser = "root";
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.pve-basicdns0;
        };
      };
    };

  pve-basicdns1 =
    let
      system = "x86_64-linux";
    in
    {
      inherit channelName system;
      modules = [ ./basicdns1/nixos.nix ];

      deploy = {
        hostname = "192.168.20.11";
        profiles.system = {
          sshUser = "root";
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.pve-basicdns1;
        };
      };
    };

  pve-dns0 =
    let
      system = "x86_64-linux";
    in
    {
      inherit channelName system;
      modules = [ ./dns0/nixos.nix ];

      deploy = {
        hostname = "192.168.20.2";
        profiles.system = {
          sshUser = "root";
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.pve-dns0;
        };
      };
    };

  pve-dns1 =
    let
      system = "x86_64-linux";
    in
    {
      inherit channelName system;
      modules = [ ./dns1/nixos.nix ];

      deploy = {
        hostname = "192.168.20.3";
        profiles.system = {
          sshUser = "root";
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.pve-dns1;
        };
      };
    };

  pve-dns2 =
    let
      system = "x86_64-linux";
    in
    {
      inherit channelName system;
      modules = [ ./dns2/nixos.nix ];

      deploy = {
        hostname = "192.168.20.4";
        profiles.system = {
          sshUser = "root";
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.pve-dns2;
        };
      };
    };

  pve-tailscale0 =
    let
      system = "x86_64-linux";
    in
    {
      inherit channelName system;
      modules = [ ./tailscale0/nixos.nix ];

      deploy = {
        hostname = "192.168.100.10";
        profiles.system = {
          sshUser = "root";
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.pve-tailscale0;
        };
      };
    };
}
