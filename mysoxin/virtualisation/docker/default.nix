{
  lib,
  mode,
  ...
}:

let
  inherit (lib) mkEnableOption optionals recursiveUpdate;
in
{
  imports =
    optionals (mode == "NixOS") [ ./nixos.nix ] ++ optionals (mode == "nix-darwin") [ ./darwin.nix ];

  options = {
    soxin.virtualisation.docker = {
      enable = mkEnableOption "Enable docker.";

      addAdminUsersToGroup = recursiveUpdate (mkEnableOption ''
        Whether to add admin users declared in soxincfg.settings.users to the `docker`
        group.
      '') { default = true; };
    };
  };
}
