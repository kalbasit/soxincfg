{ callPackage, ... }:

{
  terraform-providers.unifi = callPackage ./terraform-provider-unifi.nix { };
  zsa-auto-us-layout-switcher = callPackage ./zsa-auto-us-layout-switcher { };
}
