{
  mode,
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

          substituteInPlace $out/c \
            --subst-var-by archiver_bin ${getBin archiver}/bin/arc

          substituteInPlace $out/gcim \
            --subst-var-by git_bin ${getBin git}/bin/git

          substituteInPlace $out/jsonpp \
            --subst-var-by python_bin ${getBin python3Full}/bin/python \
            --subst-var-by pygmentize_bin ${getBin python3Packages.pygments}/bin/pygmentize

          substituteInPlace $out/jspp \
            --subst-var-by js-beautify_bin ${getBin python3Packages.jsbeautifier}/bin/js-beautify

          substituteInPlace $out/kcc \
            --subst-var-by kubectl ${getBin kubectl}/bin/kubectl

          substituteInPlace $out/kcn \
            --subst-var-by kubectl ${getBin kubectl}/bin/kubectl

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

          substituteInPlace $out/x \
            --subst-var-by archiver_bin ${getBin archiver}/bin/arc

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
      (''
        # source in the LS_COLORS
        source "${nur.repos.kalbasit.ls-colors}/ls-colors/bourne-shell.sh"

        # Enable Nix!
        # This is idempotent so no need to check if Nix is already loaded.
        if [[ -r /etc/profile.d/nix.sh ]]; then
          source /etc/profile.d/nix.sh
        elif [[ -r "${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh" ]]; then
          source "${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh"
        fi
      '')

      (optionalString stdenv.isLinux ''
        # are we running on ChromeOS
        if grep -q '^ID=debian$' /etc/os-release; then
          # workaround an issue preventing mount of /proc in user namespace
          # XXX: https://discourse.nixos.org/t/chrome-os-83-breaks-nix-sandboxing/6764/4
          sudo umount /proc/{cpuinfo,diskstats,meminfo,stat,uptime} &> /dev/null || true
        fi
      '')

      (builtins.readFile (substituteAll {
        src = ./init-extra.zsh;

        bat_bin = "${getBin bat}/bin/bat";
        fortune_bin = "${getBin fortune}/bin/fortune";
        fzf_bin = "${getBin fzf}/bin/fzf-tmux";
        home_path = "$HOME";
        jq_bin = "${getBin jq}/bin/jq";
        less_bin = "${getBin less}/bin/less";
        tput_bin = "${getBin ncurses}/bin/tput";
      }))
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

    (optionalAttrs (mode == "NixOS" || mode == "home-manager") {
      programs.zsh.shellAliases = with pkgs; {
        g = "git";

        cat = "${bat}/bin/bat";
        e = "\${EDITOR:-nvim}";
        gl = "github_commit_link";
        http = "http --print=HhBb";
        pw = "ps aux | grep -v grep | grep -e";
        rot13 = "tr \"[A-Za-z]\" \"[N-ZA-Mn-za-m]\"";
        serve_this = "${python3}/bin/python -m http.server"; # Use port 8000 by default, open in firewall
        utf8test = "${curl}/bin/curl -L https://github.com/tmux/tmux/raw/master/tools/UTF-8-demo.txt";
        vi = "nvim";
        vim = "nvim";

        # TODO: move this to the swm package
        s = "swm tmux switch-client";
        sb = "swm --story base tmux switch-client";
        vim_ready = "sleep 1";

        # TODO: move to docker-config, how to tell ZSH to import them?
        remove_created_containers = "docker rm -v \$(docker ps -a -q -f status=created)";
        remove_dangling_images = "docker rmi \$(docker images -f dangling=true -q)";
        remove_dead_containers = "docker rm -v \$(docker ps -a -q -f status=exited)";

        shabka = "t project:shabka";

        # Always enable colored `grep` output
        # Note: `GREP_OPTIONS = "--color = auto"` is deprecated, hence the alias usage.
        egrep = "egrep --color=auto";
        fgrep = "fgrep --color=auto";
        grep = "grep --color=auto";

        # send_repositories sends the repositories to apollo
        send_repositories = "${rsync}/bin/rsync -avuz --rsync-path=/usr/bin/rsync --delete --exclude=.snapshots/ --exclude=pkg/ --exclude=bin/ \"$CODE_PATH/repositories/\" apollo:/volume1/Code/repositories/";
        # send_stories sends the stories to apollo
        send_stories = "${rsync}/bin/rsync -avuz --rsync-path=/usr/bin/rsync --delete --exclude=.snapshots/ --exclude=pkg/ --exclude=bin/ \"$CODE_PATH/stories/\" apollo:/volume1/Code/stories/";

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

    (optionalAttrs (mode == "nix-darwin") (
      mkIf pkgs.stdenv.hostPlatform.isDarwin {
        # TODO: swm should parse a configuration file in order to ignore these
        # environment.shellAliases.swm = ''
        #   swm --ignore-pattern '.Spotlight-V100|.Trashes|.fseventsd'
        # '';

        programs.zsh.shellInit = ''
          if [[ -d /opt/homebrew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
          fi
        '';
      }
    ))

    (optionalAttrs (mode == "NixOS") {
      programs.zsh = {
        histSize = 1000000000;
        inherit ohMyZsh;
      };
    })

    (optionalAttrs (mode == "home-manager") {
      programs.eza = {
        enable = true;
        enableZshIntegration = true;
        extraOptions = [ "--group-directories-first" ];
      };

      programs.zsh = {
        autocd = true;
        oh-my-zsh = ohMyZsh;
        history = {
          expireDuplicatesFirst = true;
          save = 100000000;
          size = 1000000000;
        };

        initExtra = shellInit;

        plugins =
          let
            inherit (pkgs) fetchFromGitHub;
          in
          [
            {
              name = "zsh-completions";
              src = fetchFromGitHub {
                owner = "zsh-users";
                repo = "zsh-completions";
                rev = "0.34.0";
                sha256 = "sha256-qSobM4PRXjfsvoXY6ENqJGI9NEAaFFzlij6MPeTfT0o=";
              };
            }
            {
              name = "zsh-history-substring-search";
              src = fetchFromGitHub {
                owner = "zsh-users";
                repo = "zsh-history-substring-search";
                rev = "400e58a87f72ecec14f783fbd29bc6be4ff1641c";
                sha256 = "sha256-GSEvgvgWi1rrsgikTzDXokHTROoyPRlU0FVpAoEmXG4=";
              };
            }
            {
              name = "zsh-syntax-highlighting";
              src = fetchFromGitHub {
                owner = "zsh-users";
                repo = "zsh-syntax-highlighting";
                rev = "754cefe0181a7acd42fdcb357a67d0217291ac47";
                sha256 = "sha256-kWgPe7QJljERzcv4bYbHteNJIxCehaTu4xU9r64gUM4=";
              };
            }
            {
              name = "nix-shell";
              src = fetchFromGitHub {
                owner = "chisui";
                repo = "zsh-nix-shell";
                rev = "v0.6.0";
                sha256 = "sha256-B0mdmIqefbm5H8wSG1h41c/J4shA186OyqvivmSK42Q=";
              };
            }
            {
              name = "functions";
              src = myFunctions;
            }
          ];
      };

      programs.zoxide.enable = true;
    })
  ]);
}
