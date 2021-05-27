final: prev: {
  terraform-providers = prev.terraform-providers // { unifi = prev.callPackage ./terraform-provider-unifi.nix { }; };
  zsa-auto-us-layout-switcher = prev.callPackage ./zsa-auto-us-layout-switcher { };
}
