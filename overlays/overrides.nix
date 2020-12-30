pkgs-master:

final: prev: {
  inherit (pkgs-master) nixpkgs-fmt starship;
}
