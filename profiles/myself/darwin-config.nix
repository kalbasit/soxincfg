{
  config,
  lib,
  soxincfg,
  ...
}:

{
  config = {
    soxincfg.settings.users = {
      users = soxincfg.vars.users.darwin config.soxincfg.settings.users.userName;
    };

    nix.settings.trusted-users = [ config.soxincfg.settings.users.userName ];
  };
}
