{ lib, ... }:

{
  options.soxincfg.settings.macos-defaults.enable = lib.mkEnableOption ''
    opinionated macOS defaults for a workstation: Dock, Finder, Mission
    Control, keyboard, trackpad and text substitution, with screenshots in
    ~/Pictures/Screenshots. Set it in both the nix-darwin and the
    home-manager configuration of a host; the home side creates the
    screenshots directory
  '';
}
