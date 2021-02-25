final: prev: {
  terraform-providers = prev.terraform-providers // { unifi = prev.callPackage ./terraform-provider-unifi.nix { }; };
  qb64 = prev.callPackage ./qb64.nix { };
}
