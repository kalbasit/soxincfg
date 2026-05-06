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
    pkgs.git-spice
    pkgs.gnugrep
    pkgs.gnupg
    pkgs.hexyl # hex viewer with nice colors
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
    pkgs.skopeo # inspect docker images
    pkgs.turso-cli
    pkgs.unzip
    pkgs.watch
    pkgs.wget
    pkgs.yq-go
  ];
}
