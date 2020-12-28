{ ... }:

{
  imports = [
    ./coredns.nix
  ];

  services.kubernetes.addons = {
    dns.enable = false;
  };
}
