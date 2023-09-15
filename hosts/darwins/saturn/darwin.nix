{ config, lib, pkgs, inputs, soxincfg, ... }:

let
  inherit (lib)
    singleton
    ;
in
{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.workstation.darwin.local
  ]
  ++ (soxincfg.nixosModules.profiles.work.imports { hostName = "saturn"; });

  # load YL's home-manager configuration
  home-manager.users.yl = import ./home.nix { inherit soxincfg; };

  # TODO: Make gpg work, and re-enable this.
  soxincfg.programs.git.enableGpgSigningKey = false;

  nix = {
    useDaemon = true;
  };

  services.skhd = {
    enable = true;
    skhdConfig = ''
      # focus window
      alt - n : yabai -m window --focus west
      alt - e : yabai -m window --focus south
      alt - i : yabai -m window --focus north
      alt - o : yabai -m window --focus east

      # swap window
      shift + alt - n : yabai -m window --swap west
      shift + alt - e : yabai -m window --swap south
      shift + alt - i : yabai -m window --swap north
      shift + alt - o : yabai -m window --swap east

      # toggle window zoom
      alt - f : yabai -m window --toggle zoom-fullscreen
    '';
  };

  services.yabai = {
    enable = true;
    enableScriptingAddition = true;
    config = {
      # copied from the example configuration
      "active_window_border_color" = "0xff775759";
      "active_window_opacity" = "1.0";
      "auto_balance" = "off";
      "bottom_padding" = "12";
      "focus_follows_mouse" = "off";
      "insert_feedback_color" = "0xffd75f5f";
      "layout" = "bsp";
      "left_padding" = "12";
      "mouse_action1" = "move";
      "mouse_action2" = "resize";
      "mouse_drop_action" = "swap";
      "mouse_follows_focus" = "off";
      "mouse_modifier" = "fn";
      "normal_window_border_color" = "0xff555555";
      "normal_window_opacity" = "0.90";
      "right_padding" = "12";
      "split_ratio" = "0.50";
      "split_type" = "auto";
      "top_padding" = "12";
      "window_animation_duration" = "0.0";
      "window_animation_frame_rate" = "120";
      "window_border" = "off";
      "window_border_blur" = "off";
      "window_border_hidpi" = "on";
      "window_border_radius" = "12";
      "window_border_width" = "4";
      "window_gap" = "06";
      "window_opacity" = "off";
      "window_opacity_duration" = "0.0";
      "window_origin_display" = "default";
      "window_placement" = "second_child";
      "window_shadow" = "on";
      "window_topmost" = "off";
      "window_zoom_persist" = "on";
    };
  };
}
