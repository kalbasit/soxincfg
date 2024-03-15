{ soxincfg, ... }:

{
  services.k3s.extraFlags = builtins.concatStringsSep " " [
    "--node-taint nasreddine.com/is-allowed-on-prometheus=:NoExecute"
    "--node-label nasreddine.com/is-allowed-on-prometheus=yes"
  ];

  soxincfg.services.k3s = {
    enable = true;
    role = "agent";
    serverAddr = "https://192.168.50.16:6443";
  };
}
