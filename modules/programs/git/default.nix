{
  config,
  lib,
  mode,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.soxincfg.programs.git;

  package = pkgs.gitFull.override { openssh = config.programs.ssh.package; };
in
{
  options.soxincfg.programs.git = {
    enable = mkEnableOption "programs.git";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      soxin.programs.git = {
        inherit package;

        enable = true;
        lfs.enable = true;
        userName = "Wael Nasreddine";
        userEmail = "wael.nasreddine@gmail.com";
      };
    }

    (optionalAttrs (mode == "home-manager") {
      home.packages = with pkgs; [
        git-appraise
        tig
      ];

      programs.git = {
        settings = {
          alias = {
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

            show-pointer = ''!f() { git cat-file blob "HEAD:$1" }; f'';

            branches = ''
              for-each-ref --sort=-committerdate --format='%(committerdate:short) %(refname:short) %(authorname) %(authoremail)' refs/heads refs/remotes
            '';

            sp =
              let
                sp' = pkgs.writeShellScript "git-sp.sh" ''
                  set -euo pipefail

                  if ! git rev-parse --abbrev-ref --symbolic-full-name HEAD @{upstream} &> /dev/null
                  then
                    >&2 echo "Your current branch is not tracking an upstream branch, refusing to do anything."
                    >&2 echo "If your branch exists upstream then configure it with: git branch -u <upstream>/<branch_name>"
                    exit 1
                  fi

                  git pull --rebase --autostash --no-all --no-tags $(git rev-parse --abbrev-ref --symbolic-full-name HEAD @{upstream} | tail -1 | tr '/' ' ')
                '';
              in
              "!${sp'}";

            tidy =
              let
                tidy' = pkgs.writeShellScript "git-tidy.sh" ''
                  set -euo pipefail

                  source ${../zsh/plugins/functions/prompt}

                  ask=1
                  if [[ "$#" -eq 1 ]] && [[ "$1" == "-y" ]]; then
                    ask=0
                  fi

                  TIDY_BRANCHES=`comm -12 <(git branch | grep -v '\*\|master\|main' | awk '{print $1}' | sort) <(gh pr list -A "@me" --state merged --json headRefName | jq '.[].headRefName' -r | sort)`
                  for b in $TIDY_BRANCHES; do
                    if [[ "$ask" -eq 0 ]] || prompt "Delete branch? $b"; then
                      git branch -D $b
                    fi
                  done
                '';
              in
              "!${tidy'}";

            # bunch of different helpful aliases
            aa = "add --all .";
            aap = "!git aa -p";
            amend = "commit --amend";
            cb = "checkout -b";
            ci = "commit";
            ciam = "commit -a -m";
            cim = "commit -m";
            co = "checkout";
            cob = "checkout -b";
            com = "checkout master";
            credit = ''!f() { git commit --amend --author "$1 <$2>" -C HEAD; }; f'';
            dc = "diff --cached";
            di = "diff";
            fa = "fetch --all";
            famff = "!git fetch --all && git merge --ff-only origin/master";
            famm = "!git fetch --all && git merge origin/master";
            faro = "!git fetch --all && git rebase origin/master";
            generate-patch = "!git-format-patch --patch-with-stat --raw --signoff";
            l = "log --graph --pretty=format':%C(yellow)%h %Cgreen%G?%Cblue%d%Creset %s %C(white) %an, %ar%Creset'";
            lol = "log --pretty=oneline --abbrev-commit --graph --decorate --all";
            ls-ignored = "ls-files --others -i --exclude-standard";
            pob = ''!f() { git push --set-upstream "''${1:-origin}" "$(git symbolic-ref HEAD)"; }; f'';
            pobf = ''!f() { git push --set-upstream --force "''${1:-origin}" "$(git symbolic-ref HEAD)"; }; f'';
            st = "status";
            unstage = "reset HEAD --";
            who = "shortlog -s -s";
          };

          apply = {
            whitespace = "strip";
          };

          # colors copied from README of diff-so-fancy
          color = {
            pager = true;
            ui = "auto";
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

          credential."https://github.com" = {
            helper = "${pkgs.gh}/bin/gh auth git-credential";
          };

          diff-so-fancy = {
            markEmptyLines = false;
          };

          core = {
            pager = with pkgs; "${diff-so-fancy}/bin/diff-so-fancy | ${less}/bin/less --tabs=4 -RFX";
            whitespace = "trailing-space,space-before-tab,-indent-with-non-tab,cr-at-eol";
          };

          diff = {
            tool = "vimdiff";
          };

          # https://github.com/mozilla/sops#47showing-diffs-in-cleartext-in-git
          diff.sopsdiffer = {
            # https://github.com/getsops/sops/issues/884#issuecomment-1399395740
            textconv = "${pkgs.sops}/bin/sops --config /dev/null -d";
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

          init = {
            defaultBranch = "main";
          };

          merge = {
            log = true;
            tool = "vimdiff";
          };

          mergetool = {
            prompt = true;
          };

          "mergetool \"vimdiff\"" = {
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

          "filter \"lfs\"" = {
            clean = "git-lfs clean -- %f";
            smudge = "git-lfs smudge -- %f";
            process = "git-lfs filter-process";
            required = true;
          };
        };

        ignores = [
          # Direnv #
          ##########
          ".direnv/"

          # Compiled source #
          ###################
          "*.[568vq]"
          "*.a"
          "*.cgo1.go"
          "*.cgo2.c"
          "*.class"
          "*.dll"
          "*.exe"
          "*.exe"
          "*.o"
          "*.so"
          "[568vq].out"
          "_cgo_defun.c"
          "_cgo_export.*"
          "_cgo_gotypes.go"
          "_obj"
          "_test"
          "_testmain.go"

          # Ruby/Rails #
          ##############
          "**.orig"
          "*.gem"
          "*.rbc"
          "*.sassc"
          ".bundle/"
          ".sass-cache/"
          ".yardoc"
          "/public/assets/"
          "/public/index.html"
          "/public/system/*"
          "/vendor/bundle/"
          "_yardoc"
          "app/assets/stylesheets/scaffolds.css.scss"
          "capybara-*.html"
          "config/*.yml"
          "coverage/"
          "lib/bundler/man/"
          "pickle-email-*.html"
          "rerun.txt"
          "spec/reports/"
          "spec/tmp/*"
          "test/tmp/"
          "test/version_tmp/"
          "tmp/*"
          "tmp/**/*"

          # Packages #
          ############
          "*.7z"
          "*.bzip"
          "*.deb"
          "*.dmg"
          "*.egg"
          "*.gem"
          "*.gz"
          "*.iso"
          "*.jar"
          "*.lzma"
          "*.rar"
          "*.rpm"
          "*.tar"
          "*.xpi"
          "*.xz"
          "*.zip"

          # Logs and databases #
          ######################
          "*.log"
          "*.sqlite[0-9]"

          # OS generated files #
          ######################
          ".DS_Store"
          ".Spotlight-V100"
          ".Trashes/"
          "._*"
          ".directory"
          "Desktop.ini"
          "Icon?"
          "Thumbs.db"
          "ehthumbs.db"

          # Text-Editors files #
          ######################
          "*.bak"
          "*.pydevproject"
          "*.tmp"
          "*.tmproj"
          "*.tmproject"
          "*.un~"
          "*~"
          "*~.nib"
          ".*.sw[a-z]"
          ".\#*"
          ".classpath/"
          ".cproject/"
          ".elc/"
          ".loadpath/"
          ".metadata/"
          ".project/"
          ".redcar/"
          ".settings/"
          ".ycm_extra_conf.py"
          "/.emacs.desktop"
          "/.emacs.desktop.lock"
          "Session.vim"
          "\#*"
          "\#*\#"
          "auto-save-list/"
          "local.properties"
          "nbactions.xml"
          "nbproject/"
          "tmtags/"
          "tramp/"

          # Other Version Control Systems #
          #################################
          ".svn/"

          # Invert gitingore (Should be last) #
          #####################################
          "!.keep"
          "!.gitkeep"
          "!.gitignore"
        ];

        includes = [ { path = "~/.gitconfig.secrets"; } ];
      };
    })
  ]);
}
