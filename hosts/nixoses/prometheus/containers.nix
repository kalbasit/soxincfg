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
      image = "docker.io/jc21/nginx-proxy-manager:2.9.18@sha256:7364018f10033930d25d80db4c418c7c92ae3611569b61ebfeda978f8e51b1cc";
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
      image = "docker.io/octoprint/octoprint:1.8.2@sha256:5e2c3c6fbd077cc1f1407f97a36c77139d208015dd8a7d994e697b2e62728bca";
      volumes = [ "/persistence/octoprint:/octoprint" ];
    };

    containers.homeassistant = {
      dependsOn = [ "zwave2mqtt" ];
      environment.TZ = config.time.timeZone;
      extraOptions = [ "--network=${network_name}" ];
      image = "ghcr.io/home-assistant/home-assistant:stable@sha256:13821043c6428b08a0a62273b68d76abb81bfc7bd387453f2ed8aa80de72d962";
      volumes = [ "/persistence/home-assistant:/config" ];
    };

    containers.zwave2mqtt = {
      environment.TZ = config.time.timeZone;
      extraOptions = [ "--network=${network_name}" "--device=/dev/serial/by-id/usb-0658_0200-if00:/dev/zwave" ];
      image = "zwavejs/zwavejs2mqtt:8.0.1@sha256:c8fd5c959eb249cb039e7871973fd38e4345043d2d883457b257daefe33b0caa";
      volumes = [ "/persistence/zwavejs2mqtt:/usr/src/app/store" ];
    };

    containers.signal-cli-rest-api = {
      image = "bbernhard/signal-cli-rest-api:0.62@sha256:cdcd3d6f16e5057601e0912e0eb05ae657b7065e5c5347de27c95170accd5da3";
      extraOptions = [ "--network=${network_name}" ];
      environment.MODE = "json-rpc";
      volumes = [ "/persistence/signal-cli-rest-api:/home/.local/share/signal-cli" ];
    };
  };
}
