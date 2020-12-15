{ config, pkgs, lib, ... }:

{
  text = ''
    general {
      colors = true
      interval = 5
    }
    wireless _first_ {
      format_up = "W: (%quality at %essid) %ip"
      format_down = "W: down"
    }
    battery all {
      format = "%status %percentage %remaining"
    }
    tztime local {
      format = "%Y-%m-%d %H:%M:%S"
    }
    load {
      format = "%1min"
    }
    disk "/" {
      format = "%avail"
    }
    volume master {
      format = "♪: %volume"
      format_muted = "♪: muted (%volume)"
      device = "default"
    }
    cpu_temperature 0 {
      format = "%degrees °C"
    }
    order += "load"
    order += "cpu_temperature 0"
    order += "disk /"
    order += "wireless _first_"
    order += "battery all"
    order += "volume master"
    order += "tztime local"
  '';
}
