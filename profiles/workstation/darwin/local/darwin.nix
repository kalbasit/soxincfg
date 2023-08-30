{ ... }: {
  config.homebrew = {
    enable = true;

    casks = [
      "alfred" # spotlight replacement
      "charles"
      "flotato" # Makes applications of any website.
      "goland"
      "google-chrome"
      "iterm2"
      "keybase"
      "sequel-pro" # MySQL frontend supporting connections through a tunnel
      "signal"
      "slack"
      "tailscale"
      "teamviewer"
      "viscosity" # VPN Application
      "vlc"
      "whatsapp" # WhatsApp application
      "zoom"
    ];
  };
}
