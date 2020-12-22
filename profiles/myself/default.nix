{ soxincfg, lib, mode, ... }:
with lib;

{
  imports = [ ./home-secrets.nix ];

  config = mkMerge [
    (optionalAttrs (mode == "NixOS") {
      soxin = {
        # allow my user to access secrets
        users.groups = [ "keys" ];

        users.users = {
          yl = {
            inherit (soxincfg.vars.users.yl) hashedPassword sshKeys uid;
            isAdmin = true;
            home = "/yl";
          };
        };
      };
    })
  ];
}
