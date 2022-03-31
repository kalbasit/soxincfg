inputs@{ ... }:

{
  users = import ./users inputs;
  assets = import ./assets inputs;
}
