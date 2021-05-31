inputs@{ soxin, nixpkgs, ... }:

{
  penguin = {
    configuration = ./penguin/home.nix;
    homeDirectory = "/home/yl";
    username = "yl";
    system = "x86_64-linux";
  };
}
