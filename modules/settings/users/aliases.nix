# soxincfg.settings.users is Soxin's soxin.settings.users under its old name,
# so the configuration that sets it does not change.
{ config, lib, ... }:

{
  # The computed main user, read-only, so it is not an alias (an alias would
  # define Soxin's read-only option a second time).
  options.soxincfg.settings.users.user = lib.mkOption {
    type = lib.types.attrs;
    default = config.soxin.settings.users.user;
    readOnly = true;
    description = "The computed attributes of the main user (soxin.settings.users.user).";
  };

  imports =
    map
      (
        option:
        lib.mkAliasOptionModule
          [
            "soxincfg"
            "settings"
            "users"
            option
          ]
          [
            "soxin"
            "settings"
            "users"
            option
          ]
      )
      [
        "enable"
        "userName"
        "users"
        "groups"
        "defaultGroups"
      ];
}
