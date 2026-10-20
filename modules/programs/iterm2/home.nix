{ lib, ... }:

let
  inherit (lib) mkEnableOption optionals;
in
{
  imports = [ ./home-manager.nix ];

  options.soxincfg.programs.iterm2 = {
    enable = mkEnableOption "Install and configure iTerm2";

    urlHandlerCommand = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        iTerm2's `urlHandlerCommand` advanced setting (stored under the
        capitalized key `UrlHandlerCommand`, like every advanced setting): a
        command iTerm runs with `sh -c`, instead of asking macOS to open the
        URL, for every URL clicked in a terminal, OSC 8 hyperlinks included.
        It is an
        interpolated string: `\(url)` is the URL and `\(background)` is 1 when
        option was held, and the clicked session's variables (for example
        `\(profileName)`) are in scope. iTerm does not escape what it
        interpolates, so pass the URL through a quoted heredoc, not quotes.
        Null leaves the setting unset.
      '';
    };
  };
}
