final: prev: {
  terraform-providers = prev.terraform-providers // { unifi = prev.callPackage ./terraform-provider-unifi.nix { }; };
}
