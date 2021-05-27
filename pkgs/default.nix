final: prev: {
  terraform-providers = prev.terraform-providers // { unifi = prev.callPackage ./terraform-provider-unifi.nix { }; };
  zsa-auto-us-layout = prev.callPackage ./zsa-auto-us-layout { };
}
