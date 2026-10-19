{
  # hardware
  bluetooth = {
    nixos = ./hardware/bluetooth/nixos.nix;
    darwin = ./hardware/bluetooth/darwin.nix;
    home = ./hardware/bluetooth/home.nix;
  };

  # programs
  autorandr = {
    nixos = ./programs/autorandr/nixos.nix;
    darwin = ./programs/autorandr/darwin.nix;
    home = ./programs/autorandr/home.nix;
  };
  git = {
    nixos = ./programs/git/nixos.nix;
    darwin = ./programs/git/darwin.nix;
    home = ./programs/git/home.nix;
  };
  keybase = {
    nixos = ./programs/keybase/nixos.nix;
    darwin = ./programs/keybase/darwin.nix;
    home = ./programs/keybase/home.nix;
  };
  less = {
    nixos = ./programs/less/nixos.nix;
    darwin = ./programs/less/darwin.nix;
    home = ./programs/less/home.nix;
  };
  neovim = {
    nixos = ./programs/neovim/nixos.nix;
    darwin = ./programs/neovim/darwin.nix;
    home = ./programs/neovim/home.nix;
  };
  rbrowser = {
    nixos = ./programs/rbrowser/nixos.nix;
    darwin = ./programs/rbrowser/darwin.nix;
    home = ./programs/rbrowser/home.nix;
  };
  rofi = {
    nixos = ./programs/rofi/nixos.nix;
    darwin = ./programs/rofi/darwin.nix;
    home = ./programs/rofi/home.nix;
  };
  starship = {
    nixos = ./programs/starship/nixos.nix;
    darwin = ./programs/starship/darwin.nix;
    home = ./programs/starship/home.nix;
  };
  termite = {
    nixos = ./programs/termite/nixos.nix;
    darwin = ./programs/termite/darwin.nix;
    home = ./programs/termite/home.nix;
  };
  tmux = {
    nixos = ./programs/tmux/nixos.nix;
    darwin = ./programs/tmux/darwin.nix;
    home = ./programs/tmux/home.nix;
  };
  zsh = {
    nixos = ./programs/zsh/nixos.nix;
    darwin = ./programs/zsh/darwin.nix;
    home = ./programs/zsh/home.nix;
  };
  vscode = {
    nixos = ./programs/vscode/nixos.nix;
    darwin = ./programs/vscode/darwin.nix;
    home = ./programs/vscode/home.nix;
  };

  # settings
  settings = ./settings;
  # keyboard = ./settings/keyboard.nix;
  # theme = ./settings/theme.nix;
  # programmingLanguages = ./settings/programming-languages.nix;
  # tools = ./settings/tools.nix;

  # programmingLanguages
  programmingLanguages = ./programming-languages;

  # tools
  tools = ./tools;
}
