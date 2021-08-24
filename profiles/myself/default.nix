{ soxincfg, lib, mode, ... }:
with lib;

{
  imports = [ ./home-secrets.nix ];

  config = mkMerge [
    (optionalAttrs (mode == "NixOS") {
      soxincfg.settings.users = {
        # allow my user to access secrets
        groups = [ "keys" ];

        inherit (soxincfg.vars) users;
      };
    })
  ];
}
