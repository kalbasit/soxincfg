{ lib, ... }:

{
  options.soxincfg.programs.mosh.enable = lib.mkEnableOption ''
    Whether to enable mosh.
    </para><para>
    On NixOS, this installs mosh and opens ports 60000 to 61000 in your firewall.
    </para><para>
    On home-manager, this only install mosh.
  '';
}
