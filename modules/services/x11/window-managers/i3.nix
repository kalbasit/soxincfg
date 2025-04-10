{
  config,
  lib,
  mode,
  pkgs,
  ...
}:

with lib;

with lib;
let
  cfg = config.soxincfg.services.xserver.windowManager.i3;

  defaultModifier = "Mod4";
  thirdModifier = "Mod1";
  nosid = "--no-startup-id";
in
{
  options.soxincfg.services.xserver.windowManager.i3 = {
    enable = mkEnableOption "programs.i3";
  };

  config = mkIf cfg.enable (mkMerge [
    { soxin.services.xserver.windowManager.i3.enable = true; }

    (optionalAttrs (mode == "home-manager") {
      programs.pet.snippets = [
        {
          description = "i3 get-all-workspaces";
          command = "i3-msg -t get_workspaces | jq -r '.[] | .name'";
        }
        {
          description = "i3 get-current-workspace";
          command = "i3-msg -t get_workspaces | jq -r '.[] | if .focused == true then .name else empty end'";
        }
        {
          description = "github-list-stargazers";
          command = "curl -H \"Authorization: token $(cat ~/.gist)\" -H 'Accept: application/vnd.github.v3.star+json' https://api.github.com/repos/<owner>/<repo>/stargazers";
        }
      ];

      soxin.services.xserver.windowManager.bar = {
        enable = true;
        location = "top";
        modules = {
          backlight.enable = true;
          battery.enable = true;
          cpu.enable = true;
          time = {
            enable = true;

            timezones = [
              {
                timezone = "UTC";
                prefix = "UTC";
                format = "%H:%M:%S";
              }
              {
                timezone = "America/Los_Angeles";
                prefix = "PST";
                format = "%H:%M:%S";
              }
            ];
          };
          filesystems.enable = true;
          ram.enable = true;
          microphone.enable = true;
          keyboardLayout.enable = true;
          network.enable = true;
          volume.enable = true;
          temperature.enable = true;
        };
      };

      xsession.windowManager.i3.config = mkMerge [
        {
          keybindings = {
            "${defaultModifier}+${thirdModifier}+s" =
              "exec ${nosid} ${getBin pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";
          };

          startup = [
            {
              command = "${getBin pkgs.nitrogen}/bin/nitrogen --restore";
              always = false;
              notification = false;
            }
          ];
        }

        # TODO: mkIf config.soxin.settings.theme == "gruvbox-dark"
        # why this todo?
        config.soxin.settings.theme.i3.config
      ];
    })
  ]);
}
