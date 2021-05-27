# This derivation was build based on these resources:
# - https://askubuntu.com/a/337431/11272
# - https://superuser.com/a/350336/29825
# - https://github.com/zsa/wally/tree/master/dist/linux64

{ flock, gawk, lib, stdenvNoCC, writeText, writeShellScript, xorg, ... }:

let
  rule = writeText "60-zsa-auto-us-layout-switcher.rules" ''
    SUBSYSTEMS=="usb", ACTION=="add", ATTRS{idVendor}=="3297", ATTRS{idProduct}=="4976", ENV{HOME}="/yl", ENV{DISPLAY}=":0", ENV{XAUTHORITY}="/yl/.Xauthority", RUN+="@flock@/bin/flock --nonblock /tmp/switch-layout.lock -c @out@/bin/switch-layout"
    SUBSYSTEMS=="usb", ACTION=="remove", ATTRS{idVendor}=="3297", ATTRS{idProduct}=="4976", ENV{HOME}="/yl", ENV{DISPLAY}=":0", ENV{XAUTHORITY}="/yl/.Xauthority", RUN+="@out@/bin/switch-layout"
  '';

  autoswitcher = writeShellScript "zsa-auto-us-layout-switcher" ''
    set -euo pipefail

    export PATH="${flock}/bin:${gawk}/bin:${xorg.xinput}/bin:${xorg.setxkbmap}/bin:$PATH"

    log() {
      logger "[zsa-auto-us-layout-switcher] $@"
    }

    log "Starting as $(whoami) to handle the following action: $ACTION"

    log "Setting the keyboard layout to colemak"
    setxkbmap -layout us -variant colemak

    log "Setting up the options"
    setxkbmap -option ctrl:nocaps

    if [[ "$ACTION" == "add" ]]; then
      # send the loop that configures the keyboard to the background because
      # the script running blocks xinput from seeing the device and hence it
      # will never be found.
      (
        # allow only one loop to exist
        flock --nonblock 9 || exit 1

        zsa_id=
        retries=0

        while [[ -z "$zsa_id" ]] && [[ $retries -lt 20 ]]; do
          log "Getting the ID of the keyboard"
          zsa_id="$( xinput list | grep 'ZSA Technology Labs Inc ErgoDox EZ Glow' | grep keyboard | grep -v 'Glow Consumer\|Glow System\|Glow Keyboard' | awk -F'=' '{print $2}' | awk '{print $1}' || true )"
          retries=$(( retries + 1 ))
          sleep 1
        done

        if [[ -n "$zsa_id" ]]; then
          log "Setting up the US layout onto the keyboard $zsa_id"
          setxkbmap -device "$zsa_id" -layout us
        else
          log "No ID were found for the ErgoDox EZ Glow"
          exit 1
        fi
      ) 9>/tmp/switch-layout-loop.lock &
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
      --subst-var-by flock ${flock} \
      --subst-var-by out $out
  '';
}
