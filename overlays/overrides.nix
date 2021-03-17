pkgs-master:

final: prev: {
  inherit (pkgs-master) nixpkgs-fmt starship terraform terraform-providers firefox tailscale jetbrains;
}
