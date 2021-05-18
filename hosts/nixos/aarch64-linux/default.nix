{ lib, nixosSystem }:

with lib;

genAttrs [
  ./aarch64-linux-0
  ./kore
] nixosSystem
