{
  config,
  home-manager,
  pkgs,
  lib,
  soxinLib,
  ...
}:

with lib;
let
  cfg = config.soxin.programs.zsh;

  pluginsDir = "zsh/plugins";
in
{
  options = {
    soxin.programs.zsh = soxinLib.mkSoxinModule {
      inherit config;
      name = "zsh";
      includeTheme = true;
      # TODO: copied from home-manager, fix this!
      extraOptions = {
        # TODO: Consider taking this one from NixOS because of the strategy feature!
        enableAutosuggestions = mkOption {
          default = true;
          type = types.bool;
          description = "Enable zsh autosuggestions";
        };

        enableCompletion = mkOption {
          default = true;
          type = types.bool;
          description = "Enable zsh auto-completion";
        };

        plugins = mkOption {
          #
          type = types.listOf soxinLib.modules.zsh.pluginModule;
          default = [ ];
          example = literalExample ''
            [
              {
                # will source zsh-autosuggestions.plugin.zsh
                name = "zsh-autosuggestions";
                src = pkgs.fetchFromGitHub {
                  owner = "zsh-users";
                  repo = "zsh-autosuggestions";
                  rev = "v0.4.0";
                  sha256 = "0z6i9wjjklb4lvr7zjhbphibsyx51psv50gm07mbb0kj9058j6kc";
                };
              }
              {
                name = "enhancd";
                file = "init.sh";
                src = pkgs.fetchFromGitHub {
                  owner = "b4b4r07";
                  repo = "enhancd";
                  rev = "v2.2.1";
                  sha256 = "0iqa9j09fwm6nj5rpip87x3hnvbbz9w9ajgm6wkrd5fls8fn8i5g";
                };
              }
            ]
          '';
          description = "Plugins to source in <filename>.zshrc</filename>.";
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs false {
      programs.zsh = {
        inherit (cfg) enable;
      };

      # add all plugins installed by themes
      soxin.programs.zsh.plugins = cfg.theme.plugins;
    })

    # Copy the plugin management from home-manager to send plugins to NixOS and nix-darwin
    # TODO: Send it upstream to NixOS and nix-darwin.
    (optionalAttrs true (
      mkIf (cfg.plugins != [ ]) {
        # Many plugins require compinit to be called
        # but allow the user to opt out.
        soxin.programs.zsh.enableCompletion = mkDefault true;

        environment.etc = foldl' (a: b: a // b) { } (
          map (plugin: { "${pluginsDir}/${plugin.name}".source = plugin.src; }) cfg.plugins
        );

        programs.zsh.shellInit = concatStrings (
          map (plugin: ''
            path+="/etc/${pluginsDir}/${plugin.name}"
            fpath+="/etc/${pluginsDir}/${plugin.name}"
          '') cfg.plugins
        );
      }
    ))

    { }

    {
      programs.zsh = {
        inherit (cfg) enable enableCompletion;
      };
    }

    { }

    # install all completions libraries for system packages
    { }
  ]);
}
