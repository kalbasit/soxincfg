{ soxincfg, ... }:

{
  imports = [ ./home-secrets.nix ];

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
}
