{ mode, config, pkgs, lib, ... }:

with lib;
let
  cfg = config.soxin.programs.htop;
in
{
  options = {
    soxin.programs.htop = {
      enable = mkEnableOption "Whether to enable htop.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      environment.systemPackages = [ pkgs.htop ];
    })

    (optionalAttrs (mode == "home-manager") {
      programs.htop = {
        enable = true;

        colorScheme = 0;
        headerMargin = false;

        highlightBaseName = true;
        highlightMegabytes = false;
        highlightThreads = true;
        showProgramPath = false;
        showThreadNames = false;

        delay = 15;
        cpuCountFromZero = false;
        detailedCpuTime = false;
        hideKernelThreads = false;
        hideUserlandThreads = false;
        shadowOtherUsers = false;
        updateProcessNames = false;

        fields = [ "PID" "USER" "PRIORITY" "NICE" "M_SIZE" "M_RESIDENT" "M_SHARE" "STATE" "PERCENT_CPU" "PERCENT_MEM" "TIME" "COMM" ];
        meters = {
          left = [ "LeftCPUs" "Memory" "Swap" "CPU" ];
          right = [ "RightCPUs" "Tasks" "LoadAverage" "Uptime" ];
        };

        sortDescending = true;
        sortKey = "PERCENT_CPU";
        treeView = false;
      };
    })
  ]);
}
