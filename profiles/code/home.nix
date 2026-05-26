{
  config,
  pkgs,
  ...
}:

{
  # programs
  programs.bat.enable = true;
  programs.direnv.enable = true;

  # files
  home.file = {
    ".npmrc".text = "prefix=${config.home.homeDirectory}/.filesystem";

    ".ssh/id_ed25519.pub".text = ''
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJOPr+wfQrKk7xhPzaWRkaJQ7b7n1w4ivBeqDbkCTtR5 wnasreddine@pve-wnasreddine-code-01
    '';
  };

  home.packages = [
    pkgs.amazon-ecr-credential-helper
    pkgs.awscli2
    pkgs.binutils # for strings
    pkgs.bitwarden-cli
    pkgs.colordiff
    pkgs.dnsutils # for dig
    pkgs.docker-credential-gcr
    pkgs.file
    pkgs.flyctl
    pkgs.gdb
    pkgs.gh # GitHub command line client
    pkgs.ghostty.terminfo # Ghostty terminal info
    pkgs.git-spice
    pkgs.gnugrep
    pkgs.gnupg
    pkgs.hexyl # hex viewer with nice colors
    pkgs.htop
    pkgs.imagemagick # for convert
    pkgs.inetutils # for telnet
    pkgs.jq
    pkgs.killall
    pkgs.minio-client
    pkgs.nil # Nix language server
    pkgs.nix-index
    pkgs.nix-zsh-completions
    pkgs.nixd
    pkgs.nixfmt
    pkgs.psmisc
    pkgs.skopeo # inspect docker images
    pkgs.tree
    pkgs.turso-cli
    pkgs.unzip
    pkgs.watch
    pkgs.wget
    pkgs.yq-go
  ];
}
