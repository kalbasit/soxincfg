{ mode, config, pkgs, lib, ... }:

with lib;
let
  cfg = config.soxincfg.programs.htop;
in
{
  options = {
    soxincfg.programs.htop = {
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

        settings.color_scheme = 0;
        settings.header_margin = false;

        settings.highlight_base_name = true;
        settings.highlight_megabytes = false;
        settings.highlight_threads = true;
        settings.show_program_path = false;
        settings.show_thread_names = false;

        settings.delay = 15;
        settings.cpu_count_from_zero = false;
        settings.detailed_cpu_time = false;
        settings.hide_kernel_threads = false;
        settings.hide_userland_threads = false;
        settings.shadow_other_users = false;
        settings.update_process_names = false;

        settings.fields = [ "PID" "USER" "PRIORITY" "NICE" "M_SIZE" "M_RESIDENT" "M_SHARE" "STATE" "PERCENT_CPU" "PERCENT_MEM" "TIME" "COMM" ];
        settings.left_meter_modes = [ "LeftCPUs" "Memory" "Swap" "CPU" ];
        settings.right_meter_modes = [ "RightCPUs" "Tasks" "LoadAverage" "Uptime" ];

        settings.sort_direction = true;
        settings.sort_key = "PERCENT_CPU";
        settings.tree_view = false;
      };
    })
  ]);
}
