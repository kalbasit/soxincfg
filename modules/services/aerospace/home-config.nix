{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.soxincfg.services.aerospace;

  # The iTerm2 profile the story switcher opens its terminal with (see
  # darwin-config.nix). It has no parent, so it is the default profile under
  # another name: the URL handler below tells story terminals apart by it.
  storyProfile = "Story";
  dynamicProfiles = builtins.toJSON {
    Profiles = [
      {
        Name = storyProfile;
        Guid = "09E07C58-7CFD-40C8-94D7-946C7BADAACF";
      }
    ];
  };

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

  # iTerm's URL handler: every clicked URL, OSC 8 hyperlinks included, comes
  # here instead of going to macOS. Web links clicked in a story terminal go
  # to the story's Chrome window; everything else opens as before, in the
  # default browser or app. Reads the clicked session's profile name and the
  # URL from stdin, one per line.
  urlHandler = pkgs.writeShellApplication {
    name = "iterm-url-handler";
    text = ''
      background="''${1:-0}"
      IFS= read -r profile || true
      IFS= read -r url || true
      [[ -n "$url" ]] || exit 0

      if [[ "$profile" == ${lib.escapeShellArg storyProfile} && ("$url" == http://* || "$url" == https://*) ]]; then
        exec ${lib.getExe openUrl} "$url"
      fi
      if [[ "$background" == 1 || "$background" == true ]]; then
        exec /usr/bin/open -g "$url"
      fi
      exec /usr/bin/open "$url"
    '';
  };
in
{
  config = lib.mkIf (cfg.enable && pkgs.stdenv.hostPlatform.isDarwin) {
    home.file."Library/Application Support/iTerm2/DynamicProfiles/soxincfg-story.json".text =
      dynamicProfiles;

    # iTerm interpolates without escaping, and a URL can hold quotes, `;` and
    # `$(…)`, so it goes through a quoted heredoc: URLs never hold a raw
    # newline (NSURL percent-encodes it), so they cannot end the heredoc.
    soxincfg.programs.iterm2.urlHandlerCommand = ''
      ${lib.getExe urlHandler} \(background) <<'ITERM_URL'
      \(profileName)
      \(url)
      ITERM_URL
    '';
  };
}
