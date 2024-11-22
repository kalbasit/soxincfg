{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) singleton;

  nvimPkg = inputs.nixvim.packages."${pkgs.stdenv.hostPlatform.system}".default;
in
{
  home = {
    sessionVariables.EDITOR = "nvim";
    packages = singleton nvimPkg;
  };
}
