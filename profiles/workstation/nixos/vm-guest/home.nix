{
  config,
  pkgs,
  ...
}:

{
  imports = [ ../../common/home-kubernetes-client.nix ];

  # programs
  programs.bat.enable = true;
  programs.direnv.enable = true;

  # files
  home.file = {
    ".npmrc".text = "prefix=${config.home.homeDirectory}/.filesystem";
  };

  home.packages = with pkgs; [
    amazon-ecr-credential-helper
    awscli2
    binutils # for strings
    # TODO: build is failing on darwin because the dependency python3.11-agate-dbf-0.2.3 is failing.
    #csvkit
    colordiff
    docker-credential-gcr
    duf # du replacement on steroids
    file
    fx # JSON viewer
    gh # GitHub command line client
    gist
    git-quick-stats
    gnugrep
    gnupg
    go
    graphite-cli
    hexyl # hex viewer with nice colors
    imagemagick # for convert
    inetutils # for telnet
    jq
    killall
    lazygit
    lf # curses-based file manager
    mercurial
    nix-index
    nixpkgs-review
    nix-zsh-completions
    nixos-generators
    nur.repos.kalbasit.nixify
    nur.repos.kalbasit.swm
    pv # generic progress of data through a pipeline
    signal-cli
    unzip
    xsel

    #
    # Linux applications
    #

    bitwarden-cli
    # TODO: Re-enable once it builds again. It depends on libarcus and it has been marked as broken.
    # cura # slicing software for 3d printers
    dnsutils # for dig
    gdb
    glances
    gotop
    mbuffer # memory buffer within pipeline
    remmina
  ];
}
