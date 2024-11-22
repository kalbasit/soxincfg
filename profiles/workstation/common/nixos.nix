{ ... }:

{
  # L2TP VPN does not connect without the presence of this file!
  # https://github.com/NixOS/nixpkgs/issues/64965
  system.activationScripts.ipsec-secrets = ''
    touch $out/etc/ipsec.secrets
  '';
}
