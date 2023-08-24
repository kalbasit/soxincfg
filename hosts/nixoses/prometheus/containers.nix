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
      image = "docker.io/octoprint/octoprint:1.9.2@sha256:5fb961292d13d644849128ac54c778c370f70c9ca381c20792b5f3daeeb8bea2";
      volumes = [ "/persistence/octoprint:/octoprint" ];
    };

    containers.mosquitto = {
      image = "eclipse-mosquitto:2.0.17-openssl@sha256:f6f7d1728a23dc0310266075c4baf8080ad0c12048a914dbaa89490657640af9";
      extraOptions = [ "--network=${network_name}" ];
      volumes = [ "/persistence/mosquitto:/mosquitto" ];
      ports = [ "1883:1883" ];
    };

    containers.homeassistant = {
      dependsOn = [ "mosquitto" "zwave-js" ];
      environment.TZ = config.time.timeZone;
      extraOptions = [ "--network=${network_name}" ];
      image = "ghcr.io/home-assistant/home-assistant:2023.8.4@sha256:60a9b90ef0075c0cfbb088abd6a5ff609166f4cc25d8c7a2d113dac010834a0f";
      ports = [ "5683:5683/udp" ];
      volumes = [ "/persistence/home-assistant:/config" ];
    };

    containers.zwave-js = {
      environment.TZ = config.time.timeZone;
      extraOptions = [
        "--network=${network_name}"
        "--device=/dev/serial/by-id/usb-0658_0200-if00:/dev/zwave"
      ];
      image = "zwavejs/zwave-js-ui:8.23.1@sha256:197d2ba19c2fdb86180441f2ba052df0ab6d562ef9b9e1ef41b25ca820729e41";
      volumes = [ "/persistence/zwave-js:/usr/src/app/store" ];
    };

    containers.signal-cli-rest-api = {
      image = "bbernhard/signal-cli-rest-api:0.67@sha256:70871b504478a74e5ab30b6d94130d355d32300893ab2254e9aea63264121d31";
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
      image = "hertzg/rtl_433:22.11-alpine@sha256:56b1c0926f42b385b60257022be310454bae5e85fb4b93352dcbf24b80a45b36";
      extraOptions = [
        "--privileged"
        "--network=${network_name}"
      ];
      volumes = ["/dev/bus/usb:/dev/bus/usb"];
    };

    containers.rtl-433-mqtt-autodiscovery = {
      dependsOn = [ "mosquitto" ];
      image = "ghcr.io/pbkhrv/rtl_433-hass-addons-rtl_433_mqtt_autodiscovery-amd64:0.6.0@sha256:172e9636ed002bc5f8b6527ee4c488172ad14737a09e8b50f6f768e15f460774";
      extraOptions = [ "--network=${network_name}" ];
      environment.MQTT_HOST = "mosquitto";
      environment.MQTT_PORT = "1883";
      environment.DISCOVERY_INTERVAL = "60";
    };
  };
}
