{ buildHosts }:

buildHosts [
  (builtins.toString ./aarch64-linux-0)
  (builtins.toString ./kore)
]
