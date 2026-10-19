let
  advertiseRoutes = [
    "192.168.10.0/24"
    "192.168.12.0/24"
    "192.168.20.0/24"
    "192.168.30.0/24"
    "192.168.50.0/24"
    "192.168.52.0/22"
    "192.168.60.0/24"
    "192.168.61.0/24"
    "192.168.62.0/24"
    "192.168.63.0/24"
    "192.168.250.0/24"
  ];
in
{
  services.tailscale = {
    enable = true;

    disableTaildrop = true;
    extraSetFlags = [
      "--advertise-routes=${builtins.concatStringsSep "," advertiseRoutes}"
      "--snat-subnet-routes=true"
    ];
    useRoutingFeatures = "both";
  };
}
