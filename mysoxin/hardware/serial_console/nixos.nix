# soxin.hardware.serial_console comes from Soxin's library.
{ inputs, ... }:
{
  imports = [ inputs.soxin.lib.library.nixos.hardware-serial-console ];
}
