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

    containers.mosquitto = {
      image = "eclipse-mosquitto:2.0.15-openssl@sha256:9f39fb6724428c717e598522417010d5799409a761144175ed8f107e8827d381";
      extraOptions = [ "--network=${network_name}" ];
      volumes = [ "/persistence/mosquitto:/mosquitto" ];
      ports = [ "1883:1883" ];
    };

    containers.homeassistant = {
      dependsOn = [ "mosquitto" "zwave-js" ];
      environment.TZ = config.time.timeZone;
      extraOptions = [ "--network=${network_name}" ];
      image = "ghcr.io/home-assistant/home-assistant:2023.6.1@sha256:a29527b65f76ca36451aed4a4ae8859821c54e4c6d6ec70a7a6d547adb6fd2b9";
      volumes = [ "/persistence/home-assistant:/config" ];
    };

    containers.zwave-js = {
      environment.TZ = config.time.timeZone;
      extraOptions = [
        "--network=${network_name}"
        "--device=/dev/serial/by-id/usb-0658_0200-if00:/dev/zwave"
      ];
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
      image = "hertzg/rtl_433:21.12@sha256:9751f2c1561af0069cbfb67b675d9000b1fb9a5fff8d24026c2b59f5959fda55";
      extraOptions = [
        "--network=${network_name}"
        "--device=/dev/bus/usb/001/007"
      ];
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
