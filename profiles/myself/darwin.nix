{
  lib,
  mode,
  soxincfg,
  ...
}:

{
  config = {
    soxincfg.settings.users = {
      users = soxincfg.vars.users { inherit lib mode; };
    };
  };
}
