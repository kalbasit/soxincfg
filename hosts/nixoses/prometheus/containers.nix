{ config, pkgs, lib, ... }:

let
  network_name = "web_network-br";
in
{
  systemd.services.init-filerun-network-and-files = {
    description = "Create the network bridge ${network_name}.";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig.Type = "oneshot";
    script =
      let dockercli = "${config.virtualisation.docker.package}/bin/docker";
      in
      ''
        # Put a true at the end to prevent getting non-zero return code, which will
        # crash the whole service.
        check=$(${dockercli} network ls | grep "${network_name}" || true)
        if [ -z "$check" ]; then
          ${dockercli} network create ${network_name}
        else
          echo "${network_name} already exists in docker"
        fi
      '';
  };

  virtualisation.oci-containers = {
    backend = "docker";

    containers.nginx-proxy-manager = {
      extraOptions = [
        "--network=${network_name}"
        "--health-cmd=/bin/check-health"
        "--health-interval=10s"
        "--health-timeout=3s"
        "--health-start-period=20s"
      ];
      image = "docker.io/jc21/nginx-proxy-manager:2.10.3@sha256:6d854b678025781c142952a49d1378789e566b92674180cafab20210a2cae9d6";
      ports = [ "80:80" "443:443" ];
      volumes = [ "/persistence/nginx-proxy-manager/data:/data" "/persistence/nginx-proxy-manager/letsencrypt:/etc/letsencrypt" ];
    };

    containers.octoprint = {
      environment = {
        ENABLE_MJPG_STREAMER = "true";
        MJPG_STREAMER_INPUT = "-y -n -r 1920x1080";
        CAMERA_DEV = "/dev/camera";
      };
      extraOptions = [
        "--network=${network_name}"
        "--device=/dev/v4l/by-id/usb-046d_HD_Pro_Webcam_C920_CA58666F-video-index0:/dev/camera"
        "--device=/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0:/dev/printer"
      ];
      image = "docker.io/octoprint/octoprint:1.9.0@sha256:1ad8a9c24339291ad0b99d96b557a7475caa8fd2b5f6c772aeef0d3532b89035";
      volumes = [ "/persistence/octoprint:/octoprint" ];
    };

    containers.homeassistant = {
      dependsOn = [ "zwave-js" ];
      environment.TZ = config.time.timeZone;
      extraOptions = [ "--network=${network_name}" ];
      image = "ghcr.io/home-assistant/home-assistant:2023.6.1@sha256:a29527b65f76ca36451aed4a4ae8859821c54e4c6d6ec70a7a6d547adb6fd2b9";
      volumes = [ "/persistence/home-assistant:/config" ];
    };

    containers.zwave-js = {
      extraOptions = [ "--network=${network_name}" "--device=/dev/serial/by-id/usb-0658_0200-if00:/dev/zwave" ];
      image = "zwavejs/zwave-js-ui:8.19.0@sha256:94d46355d3f930579d028114117b8339d8e88181c8ee1d6ed9b9bad74fb74708";
      volumes = [ "/persistence/zwave-js:/usr/src/app/store" ];
    };

    containers.signal-cli-rest-api = {
      image = "bbernhard/signal-cli-rest-api:0.66@sha256:2f898f58bad59c4ec65e65c44d7448713d12d1564ef3528d9143e57a9c972c0d";
      extraOptions = [ "--network=${network_name}" ];
      environment.MODE = "native";
      environment.AUTO_RECEIVE_SCHEDULE = "0 22 * * *";
      volumes = [ "/persistence/signal-cli-rest-api:/home/.local/share/signal-cli" ];
    };
  };
}
