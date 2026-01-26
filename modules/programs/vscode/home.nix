{
  config,
  lib,
  pkgs,
  hostType,
  ...
}:

let
  cfg = config.soxincfg.programs.vscode;

  zshDotDir = pkgs.stdenvNoCC.mkDerivation {
    name = "zsh-dot-dir";
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out

      ln -s ${zprofile} $out/.zprofile
      ln -s ${zshenv} $out/.zshenv
    '';
  };

  zprofile = pkgs.writeText "zprofile" (
    lib.optionalString (hostType == "nix-darwin") ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
    ''
  );

  zshenv = pkgs.writeText "zshenv" ''
    source "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh"

    typeset -U path cdpath fpath manpath
    for profile in ''${(z)NIX_PROFILES}; do
      fpath+=($profile/share/zsh/site-functions $profile/share/zsh/$ZSH_VERSION/functions $profile/share/zsh/vendor-completions)
    done

    HISTFILE="${config.home.homeDirectory}/.vscode_zsh_history"
    mkdir -p "$(dirname "$HISTFILE")"

    setopt HIST_FCNTL_LOCK

    # Enabled history options
    enabled_opts=(
      HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY
    )
    for opt in "''${enabled_opts[@]}"; do
      setopt "$opt"
    done
    unset opt enabled_opts

    # Disabled history options
    disabled_opts=(
      APPEND_HISTORY EXTENDED_HISTORY HIST_FIND_NO_DUPS HIST_IGNORE_ALL_DUPS
      HIST_SAVE_NO_DUPS
    )
    for opt in "''${disabled_opts[@]}"; do
      unsetopt "$opt"
    done
    unset opt disabled_opts

    export LANG=en_US.UTF-8
    export LC_ALL="''${LANG}"
    [[ -n "''${LC_CTYPE}" ]] && unset LC_CTYPE

    # Anything got installed into MYFS?
    export MYFS="$HOME/.local"
    if [[ -d "''${MYFS}" ]]; then
      if [[ -d "''${MYFS}/bin" ]]; then
        export PATH="''${MYFS}/bin:$PATH"
      fi
    	if [[ -d "''${MYFS}/opt" ]]; then
    		for dir in ''${MYFS}/opt/*/bin; do
          export PATH="$PATH:''${dir}"
    		done

        if [[ -d "''${MYFS}/opt/go_appengine" ]]; then
          export PATH="$PATH:''${MYFS}/opt/go_appengine"
        fi
      fi

      if [[ -d "''${MYFS}/lib" ]]; then
        export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:''${MYFS}/lib"
      fi
    fi

    # add cargo
    if [[ -d "$HOME/.cargo/bin" ]]; then
      export PATH="$HOME/.cargo/bin:$PATH"
    fi

    # enable and load direnv
    eval "$(${lib.getExe config.programs.direnv.package} hook zsh)"
    eval "$(${lib.getExe config.programs.direnv.package} export zsh 2>/dev/null)"
  '';

  vscodeTerminal = pkgs.writeShellScript "vscode-terminal.sh" ''
    set -euo pipefail

    # 1. Ensure CODE_PATH is available (VS Code usually inherits env, but good to be safe)
    : "''${CODE_PATH:=$HOME/code}"

    # 2. Are we running inside Antigravity's chat?
    # If we are, execute a minimal zsh shell with the right environment variables set.
    if [[ -n "''${ANTIGRAVITY_AGENT:-}" || -n "''${ANTIGRAVITY_EDITOR_APP_ROOT:-}" ]]; then
        exec env -i \
            CODE_PATH="$CODE_PATH" \
            HOME="$HOME" \
            PWD="$PWD" \
            USER="$USER" \
            ZDOTDIR="${zshDotDir}" \
            zsh -l "$@"
    fi

    # 3. Compute the relative path
    # Remove the CODE_PATH prefix
    relative_path="''${PWD#$CODE_PATH/}"

    # 4. Strip "repositories/" if present (matching your swm behavior)
    relative_path="''${relative_path#repositories/}"

    # 5. Replace dots "." with bullets "•"
    session_name="''${relative_path//./•}"

    # 6. Compute Socket Name/Path
    # swm typically uses a socket named 'swm'.
    # Using -L swm creates/uses a socket at /tmp/tmux-<UID>/swm
    # If swm uses a specific file path (e.g. XDG_RUNTIME_DIR), use -S /path/to/socket instead.
    socket_arg="-L swm"

    # 7. Launch or Attach
    # -A: Attach if exists
    # -D: Detach others
    exec tmux $socket_arg new -AD -s "$session_name"
  '';

  terminalForHostType = type: {
    "terminal.integrated.defaultProfile.${type}" = "tmux";
    "terminal.integrated.profiles.${type}" = {
      "tmux" = {
        "path" = "${vscodeTerminal}";
        "icon" = "terminal-tmux";
      };
      "zsh" = {
        "path" = "zsh";
        "args" = [
          "-l"
        ];
      };
    };
  };
in
{
  options = {
    enable = lib.mkEnableOption "vscode";
  };

  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.antigravity;

      # TODO: Get rid of this in favor of setting up a profile with all my extensions.
      mutableExtensionsDir = true;

      profiles.default = {
        keybindings = [
          {
            key = "alt+cmd+x";
            command = "workbench.action.toggleMaximizedPanel";
            when = "panelAlignment == 'center' || panelPosition != 'bottom' && panelPosition != 'top'";
          }
        ];

        userSettings = {
          "agCockpit.telemetryDebug" = false;
          "go.toolsManagement.autoUpdate" = true;
          "python.languageServer" = "Default";
          "nix.formatterPath" = "nixfmt";
          "redhat.telemetry.enabled" = true;
          "terminal.integrated.copyOnSelection" = true;
          "files.autoSave" = "onFocusChange";
          "workbench.colorTheme" = "Catppuccin Mocha";
          "git.autofetch" = true;
          "remote.autoForwardPortsSource" = "hybrid";
          "git.blame.editorDecoration.enabled" = true;
        }
        // (terminalForHostType "osx")
        // (terminalForHostType "linux");
      };
    };
  };
}
