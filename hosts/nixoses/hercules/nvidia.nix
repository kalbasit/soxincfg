{
  lib,
  ...
}:

let
  intel_bus = "PCI:0:2:0";
  nvidia_bus = "PCI:1:0:0";
in
{
  boot = {
    initrd.kernelModules = [ "nvidia" ];
    blacklistedKernelModules = [ "nouveau" ];
    extraModprobeConfig = ''
      options nvidia "NVreg_DynamicPowerManagement=0x02"
    '';
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver = {
    videoDrivers = [ "nvidia" ];
    screenSection = ''
      Option "metamodes" "nvidia-auto-select +0+0 {ForceCompositionPipeline=On}"
      Option "AllowIndirectGLXProtocol" "off"
      Option "TripleBuffer" "on"
    '';
  };

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;

    dynamicBoost.enable = true;
    nvidiaPersistenced = true;

    powerManagement.enable = true;
    powerManagement.finegrained = false;

    prime = {
      sync.enable = true;
      intelBusId = intel_bus;
      nvidiaBusId = nvidia_bus;
    };
  };

  specialisation = {
    prime-offload.configuration = {
      system.nixos.tags = [ "prime-offload" ];
      hardware.nvidia.prime = {
        offload.enable = lib.mkForce true;
        offload.enableOffloadCmd = lib.mkForce true;
        sync.enable = lib.mkForce false;
      };
    };
    prime-reverse-sync.configuration = {
      system.nixos.tags = [ "prime-reverse-sync" ];
      hardware.nvidia.prime = {
        reverseSync.enable = lib.mkForce true;
        sync.enable = lib.mkForce false;
      };
    };
    blacklist-intel.configuration = {
      system.nixos.tags = [ "blacklist-intel" ];
      boot.kernelParams = [ "module_blacklist=i915" ];
    };
  };
}
