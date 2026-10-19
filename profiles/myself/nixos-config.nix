{
  config,
  lib,
  soxincfg,
  ...
}:

{
  config = {
    soxincfg.settings.users = {
      # allow my user to access secrets
      groups = [ "keys" ];

      users = soxincfg.vars.users.nixos config.soxincfg.settings.users.userName;
    };
  };
}
