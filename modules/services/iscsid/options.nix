{ lib, ... }:

{
  options.soxincfg.services.iscsid.enable = lib.mkEnableOption "Install and iscsi and iscsid";
}
