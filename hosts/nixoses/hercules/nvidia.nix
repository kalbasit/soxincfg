# copied from https://github.com/eureka-cpu/dotfiles/blob/tensorbook/nixos/configuration.nix

{
  config,
  pkgs,
  lib,
  ...
}:

let
  intel_bus = "PCI:0:2:0";
  nvidia_bus = "PCI:1:0:0";

  nvidia_driver = (
    config.boot.kernelPackages.nvidiaPackages.beta.overrideAttrs {
      src = pkgs.fetchurl {
        url = "https://us.download.nvidia.com/XFree86/Linux-x86_64/550.40.07/NVIDIA-Linux-x86_64-550.40.07.run";
        sha256 = "sha256-KYk2xye37v7ZW7h+uNJM/u8fNf7KyGTZjiaU03dJpK0=";
      };
    }
  );
in
{
  boot = {
    initrd.kernelModules = [ "nvidia" ];
    blacklistedKernelModules = [ "nouveau" ];
  };
  hardware.graphics = {
    enable = true; # Must be enabled
    enable32Bit = true;
  };
  services.xserver = {
    videoDrivers = [ "nvidia" ];
    screenSection = ''
      Option         "metamodes" "nvidia-auto-select +0+0 {ForceCompositionPipeline=On}"
      Option         "AllowIndirectGLXProtocol" "off"
      Option         "TripleBuffer" "on"
    '';
  };
  hardware.nvidia = {
    # Modesetting is needed for most Wayland compositors
    modesetting.enable = true;
    # Use the open source version of the kernel module
    # Only available on driver 515.43.04+
    open = false;
    # Enable the nvidia settings menu
    nvidiaSettings = true;
    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = nvidia_driver;
    # Optimus PRIME: Bus ID Values (Mandatory for laptop dGPUs)
    prime = {
      sync.enable = true;
      intelBusId = intel_bus;
      nvidiaBusId = nvidia_bus;
    };
  };
  specialisation = {
    prime-offload.configuration = {
      system.nixos.tags = [ "prime-offload" ];
      hardware.nvidia = {
        prime = {
          offload = {
            enable = lib.mkForce true;
            enableOffloadCmd = lib.mkForce true;
          };
          sync.enable = lib.mkForce false;
          intelBusId = intel_bus;
          nvidiaBusId = nvidia_bus;
        };
      };
    };
    prime-reverse-sync.configuration = {
      system.nixos.tags = [ "prime-reverse-sync" ];
      hardware.nvidia = {
        prime = {
          reverseSync.enable = lib.mkForce true;
          sync.enable = lib.mkForce false;
          intelBusId = intel_bus;
          nvidiaBusId = nvidia_bus;
        };
      };
    };
    blacklist-intel.configuration = {
      system.nixos.tags = [ "blacklist-intel" ];
      boot.kernelParams = [ "module_blacklist=i915" ];
    };
    blacklist-nvidia.configuration = {
      system.nixos.tags = [ "blacklist-nvidia" ];
      boot = {
        extraModprobeConfig = ''
          blacklist nouveau
          options nouveau modeset=0
        '';
        blacklistedKernelModules = [
          "nouveau"
          "nvidia"
          "nvidia_drm"
          "nvidia_modeset"
        ];
      };
      services.udev.extraRules = ''
        # Remove NVIDIA USB xHCI Host Controller devices, if present
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"
        # Remove NVIDIA USB Type-C UCSI devices, if present
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"
        # Remove NVIDIA Audio devices, if present
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
        # Remove NVIDIA VGA/3D controller devices
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
      '';
    };
  };
}
