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
  environment = {
    variables.EDITOR = "nvim";
    systemPackages = singleton nvimPkg;
  };
}
