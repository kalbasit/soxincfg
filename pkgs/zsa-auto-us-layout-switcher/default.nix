# This derivation was build based on these resources:
# - https://askubuntu.com/a/337431/11272
# - https://superuser.com/a/350336/29825
# - https://github.com/zsa/wally/tree/master/dist/linux64

{ stdenvNoCC, systemd, writeShellScript, writeText, ... }:

let
  background-systemd-startup = writeShellScript "background-systemd-startup.sh" ''
    set -euo pipefail

    ${systemd}/bin/systemctl start zsa-auto-us-layout-switcher.service &
  '';

  rule = writeText "60-zsa-auto-us-layout-switcher.rules" ''
    # rule for adding the keyboard
    SUBSYSTEMS=="usb", ACTION=="add", ATTRS{idVendor}=="3297", \
      ATTRS{idProduct}=="4976", \
      RUN{program}="${background-systemd-startup}"

    # rule for removing the keyboard
    SUBSYSTEMS=="usb", ACTION=="remove", ATTRS{idVendor}=="3297", \
      ATTRS{idProduct}=="4976", \
      RUN{program}="${systemd}/bin/systemctl stop zsa-auto-us-layout-switcher.service"
  '';
in stdenvNoCC.mkDerivation {
  pname = "zsa-auto-us-layout-switcher";
  version = "1.0.0";

  # it only installs files
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;
  unpackPhase = ":";

  installPhase = ''
    mkdir -p $out/lib/udev/rules.d
    substitute ${rule} $out/lib/udev/rules.d/60-zsa-auto-us-layout.rules \
      --subst-var-by out $out
  '';
}
