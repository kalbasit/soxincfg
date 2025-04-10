{
  lib,
  mode,
  soxincfg,
  ...
}:

{
  config = {
    soxincfg.settings.users = {
      # allow my user to access secrets
      groups = [ "keys" ];

      users = soxincfg.vars.users { inherit lib mode; };
    };
  };
}
