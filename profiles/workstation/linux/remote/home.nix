{
  config,
  pkgs,
  ...
}:

{
  imports = [
    ../../common/home-kubernetes-client.nix
  ];

  config = {
    # programs
    programs.bat.enable = true;
    programs.direnv.enable = true;

    # files
    home.file = {
      ".npmrc".text = "prefix=${config.home.homeDirectory}/.filesystem";
    };

    home.packages = with pkgs; [
      _2048-in-terminal
      amazon-ecr-credential-helper
      awscli2
      binutils # for strings
      bitwarden-cli
      colordiff
      devbox
      dnsutils # for dig
      docker-credential-gcr
      duf # du replacement on steroids
      esptool
      file
      fx # JSON viewer
      gdb
      gh # GitHub command line client
      gist
      gnugrep
      hexyl # hex viewer with nice colors
      imagemagick # for convert
      inetutils # for telnet
      jq
      mbuffer # memory buffer within pipeline
      mercurial
      nix-index
      nixpkgs-review
      nix-zsh-completions
      nur.repos.kalbasit.swm
      pv # generic progress of data through a pipeline
      scrcpy # mirror Android device via USB
      screen # needed to open up terminal devices
      sqlitebrowser # graphical sqlite3 client
      unzip
      yq-go
    ];
  };
}
