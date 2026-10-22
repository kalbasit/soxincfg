{
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let
  cfg = config.soxincfg.programs.zsh;
in
{
  options = {
    soxincfg.programs.zsh = {
      enable = mkEnableOption ''
        Whether to enable zsh.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    { soxin.programs.zsh.enable = true; }

    (optionalAttrs false {
      programs.zsh.shellAliases = with pkgs; {
        g = "git";

        cat = "${bat}/bin/bat";
        diff = "${colordiff}/bin/colordiff";
        e = "\${EDITOR:-nvim}";
        gl = "github_commit_link";
        http = "http --print=HhBb";
        pw = "ps aux | grep -v grep | grep -e";
        rot13 = "tr \"[A-Za-z]\" \"[N-ZA-Mn-za-m]\"";
        serve_this = "${python3}/bin/python -m http.server"; # Use port 8000 by default, open in firewall
        utf8test = "${curl}/bin/curl -L https://github.com/tmux/tmux/raw/master/tools/UTF-8-demo.txt";

        # TODO: move to docker-config, how to tell ZSH to import them?
        remove_created_containers = "docker rm -v \$(docker ps -a -q -f status=created)";
        remove_dangling_images = "docker rmi \$(docker images -f dangling=true -q)";
        remove_dead_containers = "docker rm -v \$(docker ps -a -q -f status=exited)";

        # Always enable colored `grep` output
        # Note: `GREP_OPTIONS = "--color = auto"` is deprecated, hence the alias usage.
        egrep = "egrep --color=auto";
        fgrep = "fgrep --color=auto";
        grep = "grep --color=auto";

        # send_repositories sends the repositories to redacted-host
        send_repositories = "${rsync}/bin/rsync -avuz --rsync-path=/usr/bin/rsync --delete --exclude=.snapshots/ --exclude=pkg/ --exclude=bin/ \"$CODE_PATH/repositories/\" redacted-host:/volume1/Code/repositories/";
        # send_stories sends the stories to redacted-host
        send_stories = "${rsync}/bin/rsync -avuz --rsync-path=/usr/bin/rsync --delete --exclude=.snapshots/ --exclude=pkg/ --exclude=bin/ \"$CODE_PATH/stories/\" redacted-host:/volume1/Code/stories/";

        # OS-Specific aliases
        # TODO: install this only on Mac
        #if [[ "$OSTYPE" = darwin* ]]; then  # Mac only
        #  alias mac_install_cert='sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain'
        #fi

        # use 'fc -El 1' for "dd.mm.yyyy"
        # use 'fc -il 1' for "yyyy-mm-dd"
        # use 'fc -fl 1' for mm/dd/yyyy
        history = "fc -il 1";
      };
    })

    (mkIf pkgs.stdenv.hostPlatform.isDarwin {
      programs.zsh.shellInit = ''
        if [[ -d /opt/homebrew ]]; then
          eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
      '';
    })

    { }

    { }
  ]);
}
