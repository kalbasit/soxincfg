{ lib, nixosSystem }:

with lib;

genAttrs [
  ./achilles
  ./hades
  ./x86-64-linux-0
  ./zeus
] nixosSystem
