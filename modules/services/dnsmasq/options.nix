{ lib, ... }:

{
  options.soxincfg.services.dnsmasq = {
    enable = lib.mkEnableOption "Install and configure DNSMasq";

    blockAds = lib.mkEnableOption "Automatically pull the blocklist to block all ads";
  };
}
