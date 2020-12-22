{ config, lib, mode, pkgs, ... }:

with lib;
let
  cfg = config.soxincfg.programs.ssh;

  swmSupportSendEnv = [
    "ZSH_PROFILE"
    "SWM_STORY_NAME"
    "SWM_STORY_BRANCH_NAME"
  ];
in
{
  options.soxincfg.programs.ssh.enable = mkEnableOption "Configure SSH";

  config = mkIf cfg.enable (mkMerge [
    { soxin.programs.ssh.enable = true; }

    (optionalAttrs (mode == "home-manager") {
      programs.ssh = {
        enable = true;
        compression = true;
        serverAliveInterval = 20;
        controlMaster = "auto";
        controlPersist = "yes";

        matchBlocks = {
          # special host so ssh into the VM started with nixos-start-vm
          # See soxin/programs/zsh/plugins/functions/nixos-start-vm
          hvm = {
            hostname = "localhost";
            port = 2222;
            forwardAgent = true;
            extraOptions = {
              StrictHostKeyChecking = "no";
            };
          };
        };
      };
    })
  ]);
}
