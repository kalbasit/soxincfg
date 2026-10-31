{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.soxincfg.services.aerospace;

  # AeroSpace forgets its layout when it restarts, which launchd does each
  # time it crashes, as on a display change, and puts every window on the
  # focused workspace. Save each window's workspace while it runs, and put
  # the windows back when it starts. Window ids last as long as the window,
  # so a restored window is the same one, not a new one with a reused id.
  # Run as `aerospace-layout save|restore`.
  aerospaceLayout = pkgs.writeShellApplication {
    name = "aerospace-layout";
    runtimeInputs = [
      config.services.aerospace.package
      pkgs.coreutils
      pkgs.gnused
    ];
    text = ''
      state="$HOME/Library/Application Support/aerospace-layout"
      layout="$state/windows"
      # The AeroSpace whose windows the layout holds. Saving waits for the
      # restore, else it would save every window on one workspace.
      restored="$state/restored"
      mkdir -p "$state"

      server() { /usr/bin/pgrep -x AeroSpace | head -n 1; }

      case "''${1:-}" in
      save)
        pid="$(server)" || exit 0
        [[ -n "$pid" && "$(cat "$restored" 2>/dev/null)" == "$pid" ]] || exit 0
        {
          aerospace list-workspaces --focused
          aerospace list-windows --all --format '%{window-id}|%{workspace}'
        } >"$layout.tmp"
        mv "$layout.tmp" "$layout"
        ;;
      restore)
        # The command server comes up after the startup commands run.
        for _ in $(seq 50); do
          aerospace list-workspaces --focused >/dev/null 2>&1 && break
          sleep 0.2
        done

        # Window ids start over at boot, so a layout from before it is
        # another session's.
        boot="$(/usr/sbin/sysctl -n kern.boottime | sed -E 's/.*sec = ([0-9]+).*/\1/')"
        if [[ -f "$layout" ]] && (($(stat -c %Y "$layout") > boot)); then
          declare -A current=()
          while IFS='|' read -r id ws; do
            current[$id]="$ws"
          done < <(aerospace list-windows --all --format '%{window-id}|%{workspace}')

          {
            read -r focused
            while IFS='|' read -r id ws; do
              [[ -n "''${current[$id]:-}" && "''${current[$id]}" != "$ws" ]] || continue
              aerospace move-node-to-workspace --window-id "$id" "$ws" || true
            done
          } <"$layout"
          [[ -z "$focused" ]] || aerospace workspace "$focused" || true
        fi

        server >"$restored" || true
        ;;
      *)
        echo "usage: aerospace-layout save|restore" >&2
        exit 64
        ;;
      esac
    '';
  };
in
{
  config = lib.mkIf (cfg.enable && cfg.restoreLayout) {
    services.aerospace.settings = {
      after-startup-command = [ "exec-and-forget ${lib.getExe aerospaceLayout} restore" ];
      exec-on-workspace-change = [
        (lib.getExe aerospaceLayout)
        "save"
      ];
    };

    # Moving a window to another workspace without following it, or opening
    # one, changes no workspace, so save on a timer too.
    launchd.user.agents.aerospace-layout = {
      command = "${lib.getExe aerospaceLayout} save";
      serviceConfig = {
        StartInterval = 10;
        RunAtLoad = false;
      };
    };
  };
}
