{
  config,
  lib,
  mode,
  ...
}:

let
  inherit (lib) mkEnableOption optionals;
in
{
  imports = optionals (mode == "nix-darwin") [ ./darwin.nix ];

  options.soxincfg.services.ssh-agent-mux = {
    enable = mkEnableOption "ssh-agent-mux service";
  };
}
