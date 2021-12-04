{ config, lib, mode, pkgs, ... }:


let
  inherit (lib)
    mkDefault
    mkIf
    mkMerge
    singleton
    ;

  inherit (pkgs)
    onlykey
    onlykey-agent
    onlykey-cli
    ;


  cfg = config.soxincfg.programs.onlykey;
in
{
  config = mkIf cfg.enable (mkMerge [
    { home.packages = [ onlykey onlykey-agent onlykey-cli ]; }

    (mkIf cfg.ssh-support.enable {
      soxincfg.programs.ssh = {
        identitiesOnly = mkDefault true;
        identityFiles = singleton "~/.ssh/id_ed25519_sk_rk";
      };
    })
  ]);
}
