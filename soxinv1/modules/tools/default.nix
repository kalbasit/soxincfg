{
  soxinLib,
  config,
  lib,
  ...
}:

with lib;
{
  options = {
    soxin.tools = mkOption {
      type = with types; attrsOf soxinLib.modules.tools.toolsModule;
      default = { };
    };
  };

  imports = [ ./git/default.nix ];
}
