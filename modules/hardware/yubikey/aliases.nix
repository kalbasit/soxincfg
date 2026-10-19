# soxincfg.hardware.yubikey is Soxin's soxin.hardware.yubikey under its old
# name, so the configuration that sets it does not change.
{ lib, ... }:

{
  imports =
    map
      (
        path:
        lib.mkAliasOptionModule
          (
            [
              "soxincfg"
              "hardware"
              "yubikey"
            ]
            ++ path
          )
          (
            [
              "soxin"
              "hardware"
              "yubikey"
            ]
            ++ path
          )
      )
      [
        [ "enable" ]
        [
          "gnupg-support"
          "enable"
        ]
        [
          "gnupg-support"
          "extra-socket"
        ]
        [
          "gnupg-support"
          "default-key"
        ]
        [
          "gnupg-support"
          "default-cache-ttl"
        ]
        [
          "gnupg-support"
          "max-cache-ttl"
        ]
        [
          "gnupg-support"
          "ssh-support"
          "enable"
        ]
        [
          "gnupg-support"
          "ssh-support"
          "default-cache-ttl"
        ]
        [
          "gnupg-support"
          "ssh-support"
          "max-cache-ttl"
        ]
        [
          "gnupg-support"
          "ssh-support"
          "public-certificate-pem"
        ]
      ];
}
