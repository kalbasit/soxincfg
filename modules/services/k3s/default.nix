{ lib, mode, ... }:

let
  inherit (lib)
    mkEnableOption
    mkOption
    optionals
    types
    ;
in
{
  imports = optionals (mode == "NixOS") [ ./nixos.nix ];

  options.soxincfg.services.k3s = {
    enable = mkEnableOption "Install and configure k3s either as the server or agent";

    role = mkOption {
      description = ''
        What's the role of this node?
      '';

      default = "server";
      type = types.enum [
        "server"
        "agent"
      ];
    };

    serverAddr = mkOption {
      type = types.str;
      description = lib.mdDoc ''
        The k3s server to connect to.

        Servers and agents need to communicate each other. Read
        [the networking docs](https://rancher.com/docs/k3s/latest/en/installation/installation-requirements/#networking)
        to know how to configure the firewall.
      '';
      example = "https://10.0.0.10:6443";
      default = "";
    };
  };
}
