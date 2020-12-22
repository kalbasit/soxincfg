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
          zeus = {
            hostname = "zeus.admin.nasreddine.com";
            sendEnv = swmSupportSendEnv;
            user = "root";
          };

          kore = {
            hostname = "kore.admin.nasreddine.com";
            user = "root";
          };

          apollo = {
            hostname = "apollo.nasreddine.com";
            user = "root";
            port = 54502;
          };

          serial = {
            hostname = "serial.general.nasreddine.com";
          };

          vpn = {
            hostname = "vpn.nasreddine.com";
            user = "root";
          };

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
