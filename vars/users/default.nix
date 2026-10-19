# The users of the fleet, by kind: `nixos userName` and `darwin userName`.
{
  nixos = import ./nixos.nix;
  darwin = import ./darwin.nix;
}
