{ config, lib, mode, pkgs, ... }:

let
  inherit (lib)
    mkIf
    mkMerge
    ;
in
{
  config = mkMerge [
    (mkIf config.soxincfg.programs.ssh.enable {
      home.file = {
        ".ssh/per-host/linnaeus.io_rsa.pub".text = ''
          ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJ7xRFrvj2HwbZxfxSL5YNiSX0LPZW1C4phOuGIWGpCtr/zfLRZx69biuhva5cyfOBLyT9p8+aa7E3wy8dzkI/BKNi/UFhmemCkqQE+hCgbi9GGal7iUSPd5FtQLHLZ5YDcJLPD6bYNJUI9bK8vm/k2HQJVggrQPvM4BCTugFOVcoWiyVk3VXMR/Z4CTi6yWKcPO1+zDFh8mMiZm20z81W4Usl/z+c16OnHu6rSsUBLsowbwDRIa7pymgVbODJbym0Ktf6reYYtUhTefC5JdF4Goj85B8mqSGUN6YGmP4pVgbjncSjWTymaSiTYQkyugEXNYmGbpnhi89gopCGPFIiXie+NGoa1t/CQ3iXgIb4BJ+YJ2uBXrnyFkysCcd+ESV9Z5Tif9lF8O65rEyVHWbBSNM7fGmcxje0A4ygO66saVxlkvFMSLtPAkKIMmq0tNTQ0tbXPllSdkphSGBEyCa+AgIyHts2tX3zNuzG7yRl/FCjpQLp8KCbJoZBzu4pfKVWrznDpphWgqY3Y1h5kjWGSOLZEwmKDXsjW+9Tn8DYDKq/8hcPxWeObuHgfkvO2cl4+cPOszpqzZScHBIIkh8i85Ad+5Ild7J92H0D9hw12zrg5bHWCVqH4WGsNDd/8h9gX2zNjgmYbCbVOYdn4sm6rbTtckMCSKloftR1cY/Mow== linnaeus.io
        '';
      };

      programs.ssh = {
        extraConfig = ''
          Include ~/.ssh/config_include_work_ulta
        '';
      };
    })
  ];
}
