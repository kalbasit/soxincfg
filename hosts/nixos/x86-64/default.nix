{ buildHosts }:

buildHosts [
  (builtins.toString ./achilles)
  (builtins.toString ./hades)
  (builtins.toString ./x86-64-linux-0)
  (builtins.toString ./zeus)
]
