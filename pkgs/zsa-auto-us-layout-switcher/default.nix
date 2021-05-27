# This derivation was build based on these resources:
# - https://askubuntu.com/a/337431/11272
# - https://superuser.com/a/350336/29825
# - https://github.com/zsa/wally/tree/master/dist/linux64

{ gawk, lib, stdenvNoCC, writeText, writeShellScript, xorg, ... }:

let
  rule = writeText "60-zsa-auto-us-layout-switcher.rules" ''
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", ATTRS{idProduct}=="4976",RUN+="@out@/bin/switch-layout"
  '';

  autoswitcher = writeShellScript "zsa-auto-us-layout-switcher" ''
    set -euo pipefail

    export PATH="${xorg.xinput}/bin:${gawk}/bin:${xorg.setxkbmap}/bin:$PATH"

    log() {
      logger "[zsa-auto-us-layout-switcher] $@"
    }

    log "Starting as $(whoami)"

    sleep 1
    export HOME=/yl
    export DISPLAY=":0.0"
    export XAUTHORITY=$HOME/.Xauthority

    log "Getting the ID of the keyboard"
    zsa_id="$( xinput list | grep 'ZSA Technology Labs Inc ErgoDox EZ Glow' | grep keyboard | grep -v 'Glow Consumer\|Glow System\|Glow Keyboard' | awk -F'=' '{print $2}' | awk '{print $1}' )"

    log "Setting the keyboard layout to colemak"
    setxkbmap -layout us -variant colemak

    log "Setting up the options"
    setxkbmap -option ctrl:nocaps

    if [[ -n "$zsa_id" ]]; then
      log "Setting up the US layout onto the keyboard $zsa_id"
      setxkbmap -device "$zsa_id" -layout us
    fi
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
    mkdir -p $out/bin
    cp ${autoswitcher} $out/bin/switch-layout

    mkdir -p $out/lib/udev/rules.d
    substitute ${rule} $out/lib/udev/rules.d/60-zsa-auto-us-layout.rules \
      --subst-var-by out $out
  '';
}
