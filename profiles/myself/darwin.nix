{
  config,
  lib,
  mode,
  soxincfg,
  ...
}:

{
  config = {
    soxincfg.settings.users = {
      users = soxincfg.vars.users {
        inherit lib mode;
        inherit (config.soxincfg.settings.users) userName;
      };
    };

    nix.settings.trusted-users = [ config.soxincfg.settings.users.userName ];
  };
}
