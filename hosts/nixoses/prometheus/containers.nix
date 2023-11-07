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
      image = "docker.io/jc21/nginx-proxy-manager:2.10.4@sha256:3d1f678a0638a82abb88deb0cef710f77e5a9f5736d97a556cdd131512da5d3f";
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
      image = "docker.io/octoprint/octoprint:1.9.3@sha256:1e48b53ab15e740e42d29a54b44efa4283d10d9a00aa21fa84f37a869ad0e81c";
      volumes = [ "/persistence/octoprint:/octoprint" ];
    };

    containers.mosquitto = {
      image = "eclipse-mosquitto:2.0.18-openssl@sha256:000a1baa31419cf1f271cfeb8740952f1e125f826206f7b277aa187131806866";
      extraOptions = [ "--network=${network_name}" ];
      volumes = [ "/persistence/mosquitto:/mosquitto" ];
      ports = [ "1883:1883" ];
    };

    containers.homeassistant = {
      dependsOn = [ "mosquitto" "zwave-js" ];
      environment.TZ = config.time.timeZone;
      extraOptions = [ "--network=${network_name}" ];
      image = "ghcr.io/home-assistant/home-assistant:2023.11.1@sha256:9fd01a2dc6294555048f08f344900e998be0aa89d86d6273b5f1bd2554a7bb73";
      ports = [ "5683:5683/udp" ];
      volumes = [ "/persistence/home-assistant:/config" ];
    };

    containers.zwave-js = {
      environment.TZ = config.time.timeZone;
      extraOptions = [
        "--network=${network_name}"
        "--device=/dev/serial/by-id/usb-0658_0200-if00:/dev/zwave"
      ];
      image = "zwavejs/zwave-js-ui:9.3.1@sha256:8a98d1ab0da008d716c1f24f92497c85d65c1281adfe766037c29517212cadc3";
      volumes = [ "/persistence/zwave-js:/usr/src/app/store" ];
    };

    containers.signal-cli-rest-api = {
      image = "bbernhard/signal-cli-rest-api:0.70@sha256:8871a51a6cb898e5b49e1839fb0b1109e608919db2cae7f0a49fbfe342e8c807";
      extraOptions = [ "--network=${network_name}" ];
      environment.MODE = "native";
      environment.AUTO_RECEIVE_SCHEDULE = "0 22 * * *";
      volumes = [ "/persistence/signal-cli-rest-api:/home/.local/share/signal-cli" ];
    };

    containers.rtl-433 = {
      cmd = [
        "-Mtime:unix:usec:utc"
        "-Mbits"
        "-Mlevel"
        "-Mprotocol"
        "-Mstats:2:300"
        "-Fmqtt://mosquitto:1883,retain=1"
      ];
      dependsOn = [ "mosquitto" ];
      image = "hertzg/rtl_433:22.11-alpine@sha256:cded9f8bb755a9157a26f672202d30770c5e13e1b57525791ce227c7fd41e218";
      extraOptions = [
        "--privileged"
        "--network=${network_name}"
      ];
      volumes = [ "/dev/bus/usb:/dev/bus/usb" ];
    };

    containers.rtl-433-mqtt-autodiscovery = {
      dependsOn = [ "mosquitto" ];
      image = "ghcr.io/pbkhrv/rtl_433-hass-addons-rtl_433_mqtt_autodiscovery-amd64:0.7.0@sha256:c4c87de2058fda1b73061a5be23db3bed1750fd33113dae14fb119ed4ce2068d";
      extraOptions = [ "--network=${network_name}" ];
      environment.MQTT_HOST = "mosquitto";
      environment.MQTT_PORT = "1883";
      environment.DISCOVERY_INTERVAL = "60";
    };
  };
}
