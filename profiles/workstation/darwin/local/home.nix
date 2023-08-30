{ pkgs, ... }:

{
  home.packages = with pkgs; [
    openssh
  ];
}
