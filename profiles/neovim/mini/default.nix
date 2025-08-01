{
  inputs,
  pkgs,
  ...
}:

{
  soxincfg.programs.neovim = {
    enable = true;

    package = inputs.nixvim.packages."${pkgs.stdenv.hostPlatform.system}".small;
  };
}
