{
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let
  cfg = config.soxincfg.programs.zsh;

  myFunctions =
    with pkgs;
    stdenvNoCC.mkDerivation rec {
      name = "zsh-functions-${version}";
      version = "0.0.1";
      src = ./plugins/functions;
      phases = [ "installPhase" ];
      installPhase = builtins.concatStringsSep "\n\n" [
        ''
          mkdir $out

          cp $src/* $out/

          rm -f $out/default.nix

          substituteInPlace $out/gcim \
            --subst-var-by git_bin ${getBin git}/bin/git

          substituteInPlace $out/jsonpp \
            --subst-var-by python_bin ${getBin python3}/bin/python \
            --subst-var-by pygmentize_bin ${getBin python3Packages.pygments}/bin/pygmentize

          substituteInPlace $out/jspp \
            --subst-var-by js-beautify_bin ${getBin python3Packages.jsbeautifier}/bin/js-beautify

          substituteInPlace $out/sapg \
            --subst-var-by apg_bin ${getBin apg}/bin/apg

          substituteInPlace $out/ulimit_usage \
            --subst-var-by paste_bin ${getBin coreutils}/bin/paste \
            --subst-var-by cut_bin ${getBin coreutils}/bin/cut \
            --subst-var-by awk_bin ${getBin gawk}/bin/awk \
            --subst-var-by lsof_bin ${getBin lsof}/bin/lsof \
            --subst-var-by sed_bin ${getBin gnused}/bin/sed \
            --subst-var-by bc_bin ${getBin bc}/bin/bc

          substituteInPlace $out/vim_clean_swap \
            --subst-var-by vim_bin ${getBin vim}/bin/vim

          substituteInPlace $out/xmlpp \
            --subst-var-by xmllint_bin ${getBin libxml2Python}/bin/xmllint
        ''

        (optionalString stdenv.isLinux ''
          substituteInPlace $out/mkfs.enc \
            --subst-var-by cryptsetup_bin ${getBin cryptsetup}/bin/cryptsetup \
            --subst-var-by mkfs_ext2_bin ${getBin e2fsprogs}/bin/mkfs.ext2

          substituteInPlace $out/mount.enc \
            --subst-var-by cryptsetup_bin ${getBin cryptsetup}/bin/cryptsetup \
            --subst-var-by bw_bin ${getBin bitwarden-cli}/bin/bw \
            --subst-var-by jq_bin ${getBin jq}/bin/jq \
            --subst-var-by lpass_bin ${getBin lastpass-cli}/bin/lpass

          substituteInPlace $out/umount.enc \
            --subst-var-by cryptsetup_bin ${getBin cryptsetup}/bin/cryptsetup

          substituteInPlace $out/register_u2f \
            --subst-var-by pamu2fcfg_bin ${getBin pam_u2f}/bin/pamu2fcfg
        '')

        (optionalString stdenv.isDarwin ''
          rm -f $out/mkfs.enc $out/mount.enc $out/umount.enc $out/register_u2f
        '')
      ];
    };

  ohMyZsh = {
    enable = true;
    plugins = [
      "command-not-found"
      "history"
      "sudo"
    ];
  };

  shellInit =
    with pkgs;
    builtins.concatStringsSep "\n\n" [
      ''
        # Enable Nix!
        # This is idempotent so no need to check if Nix is already loaded.
        if [[ -r /etc/profile.d/nix.sh ]]; then
          source /etc/profile.d/nix.sh
        elif [[ -r "${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh" ]]; then
          source "${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh"
        fi
      ''

      (optionalString stdenv.isLinux ''
        # are we running on ChromeOS
        if grep -q '^ID=debian$' /etc/os-release; then
          # workaround an issue preventing mount of /proc in user namespace
          # XXX: https://discourse.nixos.org/t/chrome-os-83-breaks-nix-sandboxing/6764/4
          sudo umount /proc/{cpuinfo,diskstats,meminfo,stat,uptime} &> /dev/null || true
        fi
      '')

      (builtins.readFile (
        replaceVars ./init-extra.zsh {
          bat_bin = "${getBin bat}/bin/bat";
          fortune_bin = "${getBin fortune}/bin/fortune";
          fzf_bin = "${getBin fzf}/bin/fzf-tmux";
          home_path = "$HOME";
          jq_bin = "${getBin jq}/bin/jq";
          less_bin = "${getBin less}/bin/less";
        }
      ))

      # TODO: Move this to pet once there is a way to put stuff at the bottom
      (optionalString config.programs.pet.enable ''
        function pet_select() {
          BUFFER=$(pet search --query "$LBUFFER")
          CURSOR=$#BUFFER
          zle redisplay
        }
        function pet_prev() {
          PREV=$(fc -lrn | head -n 1)
          sh -c "pet new $(printf %q "$PREV")"
        }
        if [[ -o interactive ]]; then
          zle -N pet_select
          stty -ixon
          bindkey '^p' pet_select
        fi
      '')

      # enable worktree
      ''
        eval "$(${pkgs.worktrunk}/bin/wt config shell init zsh)"
      ''
    ];
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
