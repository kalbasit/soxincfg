{
  mode,
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let
  cfg = config.soxincfg.programs.weechat;

  weechat-home =
    with pkgs;
    stdenvNoCC.mkDerivation {
      name = "weechat-home";
      src = ./config;
      unpackPhase = ":";

      preferLocalBuild = true;
      allowSubstitutes = false;

      installPhase = ''
        mkdir $out

        ln -s ${config.home.homeDirectory}/.weechat/buddylist.txt $out/buddylist.txt
        ln -s ${config.home.homeDirectory}/.weechat/logs $out/logs
        ln -s ${config.home.homeDirectory}/.weechat/urlserver_list.txt $out/urlserver_list.txt
        ln -s ${config.home.homeDirectory}/.weechat/weechat.log $out/weechat.log

        ${rsync}/bin/rsync --exclude '*.sops' -avz $src/ $out/
      '';
    };

  owner = config.users.users.yl.name;
in
{
  options = {
    soxincfg.programs.weechat = {
      enable = mkEnableOption "WeeChat IRC client";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      sops.secrets."_config_weechat_certs_freenode.pem" = {
        inherit owner;
        format = "binary";
        sopsFile = ./config/certs/freenode.pem.sops;
      };
      sops.secrets."_config_weechat_irc.conf" = {
        inherit owner;
        format = "binary";
        sopsFile = ./config/irc.conf.sops;
      };
      sops.secrets."_config_weechat_sec.conf" = {
        inherit owner;
        format = "binary";
        sopsFile = ./config/sec.conf.sops;
      };
    })

    (optionalAttrs (mode == "home-manager") {
      programs.zsh.shellAliases.weechat = "tmux -L weechat attach -t weechat";

      home.activation.weechat = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p ${config.home.homeDirectory}/.weechat/logs

        chmod 711 ${config.home.homeDirectory}/.weechat

        touch ${config.home.homeDirectory}/.weechat/buddylist.txt
        touch ${config.home.homeDirectory}/.weechat/urlserver_list.txt
        touch ${config.home.homeDirectory}/.weechat/weechat.log

        chmod 511 ${config.home.homeDirectory}/.weechat
      '';

      home.packages = singleton (
        pkgs.writeShellScriptBin "edit-weechat-config" ''
          set -euo pipefail

          local_dir="$(${config.programs.ssh.package}/bin/git rev-parse --show-toplevel)/modules/programs/weechat/config"
          if ! [[ -d "$local_dir" ]]; then
            echo "Please run this script from within soxincfg"
            exit 1
          fi

          temp_dir="$(mktemp -d)"
          ${pkgs.rsync}/bin/rsync -auz "$local_dir/" "$temp_dir/"

          cd "$temp_dir"
          for i in $(find . -name '*.sops'); do
            rm -f "''${i%%.sops}"
            ${pkgs.sops}/bin/sops -d "$i" > "''${i%%.sops}"
          done

          export WEECHAT_HOME="$temp_dir"
          ${pkgs.weechat}/bin/weechat

          for i in $(find . -name '*.sops'); do
            ${pkgs.sops}/bin/sops -e "''${i%%.sops}" > "$i"
            rm -f "''${i%%.sops}"
          done

          # remove symlinks I added myself
          rm -rf buddylist.txt logs urlserver_list.txt weechat.log

          ${pkgs.rsync}/bin/rsync -auz "$temp_dir/" "$local_dir/"

          cd -
          rm -rf "$temp_dir"
        ''
      );

      # NOTE: Only works well with lingering enabled -- otherwise systemd might kill
      # the service on logout (aka once there are no more user sessions)
      # If you need to run this on a server then enable lingering session:
      #   sudo loginctl enable-linger $USER
      systemd.user.services."weechat" = {
        Unit = {
          Description = "A WeeChat client and relay service using Tmux";
          After = "network.target";
          Before = "shutdown.target";
          Conflicts = "shutdown.target";
        };

        Service = {
          Type = "forking";
          ExecStart = "${pkgs.tmux}/bin/tmux -L weechat new-session -s weechat -d ${pkgs.weechat}/bin/weechat";
          ExecStartPost = "${pkgs.tmux}/bin/tmux -L weechat set status"; # turn off the status bar
          ExecStop = "-${pkgs.tmux}/bin/tmux -L weechat kill-server";

          Environment =
            let
              secureSocket = config.programs.tmux.enable && config.programs.tmux.secureSocket;
            in
            [ "WEECHAT_HOME=${weechat-home}" ] ++ (optionals secureSocket [ "TMUX_TMPDIR=/run/user/2000" ]); # TODO: Do not hardcode my uid
        };

        Install.WantedBy = [ "default.target" ];
      };
    })
  ]);
}
