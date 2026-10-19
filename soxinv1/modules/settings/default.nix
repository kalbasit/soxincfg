{
  config,
  lib,
  ...
}:

with lib;
{
  imports = [
    ./programming-languages.nix
    ./tools.nix
  ];
}
