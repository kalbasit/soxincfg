{ config, lib, mode, pkgs, ... }:

with lib;
let
  cfg = config.soxincfg.programs.git;
in
{
  options.soxincfg.programs.git = {
    enable = mkEnableOption "programs.git";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      soxin.programs.git = {
        enable = true;
        userName = "Wael M. Nasreddine";
        userEmail = "wael.nasreddine@gmail.com";
        gpgSigningKey = "me@yl.codes";
      };
    }

    (optionalAttrs (mode == "home-manager") {
      home.packages = with pkgs; [
        gitAndTools.git-appraise
        gitAndTools.tig
        git-lfs
      ];

      programs.git.aliases = {
        # list files which have changed since REVIEW_BASE
        # (REVIEW_BASE defaults to 'master' in my zshrc)
        files = ''!git diff --name-only ''$(git merge-base HEAD "''${REVIEW_BASE:-master}")'';

        # Same as above, but with a diff stat instead of just names
        # (better for interactive use)
        stat = ''!git diff --stat ''$(git merge-base HEAD ''${REVIEW_BASE:-master})'';

        # Open all files changed since REVIEW_BASE in Vim tabs
        # Then, run fugitive's :Gdiff in each tab, and finally
        review = ''!nvim ''$(git files) +"tabdo Gdiff ''${REVIEW_BASE:-master}"'';

        # Same as the above, except specify names of files as arguments,
        # instead of opening all files:
        # git reviewone foo.js bar.js
        reviewone = ''!nvim -p +"tabdo Gdiff ''${REVIEW_BASE:-master}"'';

        branches = ''
          ! # go to shell command mode
          bo() {
            local branch
            for branch in $(git branch | sed s/^..//); do
              echo -e "$(git log -1 --pretty=format:"%Cgreen%ci %Cblue%cr%Creset" "''${branch}")\t''${branch}"
            done | sort -r
          }
          bo
        '';
      };

      programs.git.extraConfig = {
        # colors copied from README of diff-so-fancy
        color = {
          diff-highlight = {
            newHighlight = "green bold 22";
            newNormal = "green bold";
            oldHighlight = "red bold 52";
            oldNormal = "red bold";
          };

          diff = {
            commit = "yellow bold";
            frag = "magenta bold";
            meta = "11";
            new = "green bold";
            old = "red bold";
            whitespace = "red reverse";
          };
        };

        diff-so-fancy = {
          markEmptyLines = false;
        };

        core = {
          pager = with pkgs; "${gitAndTools.diff-so-fancy}/bin/diff-so-fancy | ${less}/bin/less --tabs=4 -RFX";
          whitespace = "trailing-space,space-before-tab,-indent-with-non-tab,cr-at-eol";
        };

        diff = {
          tool = "vimdiff";
        };

        difftool = {
          prompt = false;
        };

        help = {
          autocorrect = 30;
        };

        http = {
          cookiefile = "~/.gitcookies";
        };

        "http \"https://gopkg.in\"" = {
          followRedirects = true;
        };

        merge = {
          log = true;
          tool = "vimdiff";
        };

        mergetool = {
          prompt = true;
        };

        "mergetool \"vimdiff\"" = optionalAttrs config.soxin.programs.neovim.enable {
          cmd = "nvim -d $LOCAL $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";
        };

        "protocol \"keybase\"" = {
          allow = "always";
        };

        push = {
          default = "current";
        };

        sendemail = {
          smtpserver = "${pkgs.msmtp}/bin/msmtp";
          smtpserveroption = "--account=personal";
        };

        status = {
          submodule = 1;
        };

        "url \"https://github\"" = {
          insteadOf = "git://github";
        };

        "filter \"lfs\"" = {
          clean = "git-lfs clean -- %f";
          smudge = "git-lfs smudge -- %f";
          process = "git-lfs filter-process";
          required = true;
        };
      };
    })
  ]);
}
