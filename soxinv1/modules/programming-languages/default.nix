{
  soxinLib,
  config,
  lib,
  ...
}:

with lib;
{
  options = {
    soxin.programmingLanguages = mkOption {
      type = with types; attrsOf soxinLib.modules.programmingLanguages.programmingLanguages;
      default = { };
    };
  };

  imports = [ ./go/default.nix ];
}
