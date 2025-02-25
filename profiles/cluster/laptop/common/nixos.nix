{
  soxincfg,
  nixos-hardware,
  ...
}:

{
  imports = [
    soxincfg.nixosModules.profiles.server

    nixos-hardware.nixosModules.apple-macbook-air-3
  ];

  soxin.hardware.lowbatt.enable = true;

  # Don't allow systemd to stop the Tailscale service because that wreck havoc
  # on my network and containers.
  systemd.services.tailscaled.restartIfChanged = false;

  # https://www.reddit.com/r/NixOS/comments/14qa7d8/comment/jqo1cpw/?utm_source=share&utm_medium=web2x&context=3
  services = {
    logind = {
      lidSwitch = "ignore";
      extraConfig = ''
        HandlePowerKey=ignore
      '';
    };
    acpid = {
      enable = true;
      lidEventCommands = ''
        export PATH=$PATH:/run/current-system/sw/bin

        lid_state=$(cat /proc/acpi/button/lid/LID0/state | awk '{print $NF}')
        if [ $lid_state = "closed" ]; then
          # Set brightness to zero
          echo 0  > /sys/class/backlight/acpi_video0/brightness
        else
          # Reset the brightness
          echo 50  > /sys/class/backlight/acpi_video0/brightness
        fi
      '';

      powerEventCommands = "systemctl suspend";
    };
  };
}
