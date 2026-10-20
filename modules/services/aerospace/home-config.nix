{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.soxincfg.services.aerospace;

  # Open a URL in the Chrome window of the focused AeroSpace workspace, the
  # one the story switcher opened next to the terminal. A plain `open -a`
  # would use Chrome's last active window, which can sit on another story's
  # workspace, and AeroSpace would follow it there.
  openUrl = pkgs.writeShellApplication {
    name = "aerospace-story-open-url";
    runtimeInputs = [ pkgs.aerospace ];
    text = ''
      url="''${1:?usage: aerospace-story-open-url <url>}"

      workspace="$(aerospace list-workspaces --focused)"
      window="$(aerospace list-windows --workspace "$workspace" --app-bundle-id com.google.Chrome --format '%{window-id}')"
      window="''${window%%$'\n'*}"

      if [[ -n "$window" ]]; then
        aerospace focus --window-id "$window"
        /usr/bin/open -a "Google Chrome" "$url"
      else
        /usr/bin/open -na "Google Chrome" --args --new-window "$url"
      fi
    '';
  };
in
{
  # The iTerm2 profile the story switcher opens its terminal with (see
  # darwin-config.nix). It has no parent, so it inherits every setting of the
  # default profile, and only replaces the smart selection rules: iTerm's
  # defaults, with an action on HTTP URLs. Cmd-click runs a matching rule's
  # first action before iTerm's own URL handling, so links open in the
  # story's Chrome window; every other profile keeps the system browser.
  config = lib.mkIf (cfg.enable && pkgs.stdenv.hostPlatform.isDarwin) {
    home.file."Library/Application Support/iTerm2/DynamicProfiles/soxincfg-story.json".text =
      builtins.replaceStrings [ "@openUrl@" ] [ (lib.getExe openUrl) ]
        (builtins.readFile ./iterm2-story-profile.json);
  };
}
