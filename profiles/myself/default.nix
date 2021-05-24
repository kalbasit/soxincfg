{ soxincfg, lib, mode, ... }:
with lib;

{
  imports = [ ./home-secrets.nix ];

  config = mkMerge [
    (optionalAttrs (mode == "NixOS") {
      soxincfg.settings.users = {
        # allow my user to access secrets
        groups = [ "keys" ];

        users = {
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
