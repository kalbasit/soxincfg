{ buildHosts }:

buildHosts [
  (builtins.toString ./penguin)
]
