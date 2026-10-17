# The darwin module: the options, and the configuration one level below, where
# it sat when a `mode` switch imported it, so its list definitions keep their
# order.
{
  imports = [
    ./options.nix
    ./darwin-config.nix
  ];
}
