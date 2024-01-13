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

  virtualisation.docker.listenOptions = [
    "/run/docker.sock"
    "38561"
  ];

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
      ports = [
        # required for the migration to the new cluster
        "5000:5000"
        "8088:8080"
      ];
    };

    containers.homeassistant = {
      environment.TZ = config.time.timeZone;
      extraOptions = [ "--network=${network_name}" ];
      image = "ghcr.io/home-assistant/home-assistant:2024.1.1@sha256:c0752d4901483e0116120bc44230af5793d32bd337730e5d06bef2930e289dce";
      ports = [
        "5683:5683/udp"

        # required for the migration to the new cluster
        "8123:8123"
      ];
      volumes = [ "/persistence/home-assistant:/config" ];
    };

  };
}
