{ config, pkgs, lib, ... }:

let
  podman-web-bridge = pkgs.writeText "88-podman-web-bridge.conflist" ''
    {
       "cniVersion": "0.4.0",
       "name": "${network_name}",
       "plugins": [
          {
             "type": "bridge",
             "bridge": "cni-podman3",
             "isGateway": true,
             "ipMasq": true,
             "hairpinMode": true,
             "ipam": {
                "type": "host-local",
                "routes": [
                   {
                      "dst": "0.0.0.0/0"
                   }
                ],
                "ranges": [
                   [
                      {
                         "subnet": "10.89.1.0/24",
                         "gateway": "10.89.1.1"
                      }
                   ]
                ]
             }
          },
          {
             "type": "portmap",
             "capabilities": {
                "portMappings": true
             }
          },
          {
             "type": "firewall",
             "backend": ""
          },
          {
             "type": "tuning"
          },
          {
             "type": "dnsname",
             "domainName": "dns.podman",
             "capabilities": {
                "aliases": true
             }
          }
       ]
    }
  '';

  network_name = "web_network_default";
in
{
  # define the network interface
  environment.etc."cni/net.d/88-podman-web-bridge.conflist".source = podman-web-bridge;
  # the network interface needs the dnsname plugin
  virtualisation.containers.containersConf.cniPlugins = [ pkgs.dnsname-cni ];

  virtualisation.oci-containers = {
    backend = "podman";

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
      image = "docker.io/octoprint/octoprint@sha256:ffa5005afc33511df2c03780ef92727137661a917a213e9f03cb13040c1ac59c";
      volumes = [ "/persistence/octoprint:/octoprint" ];
    };

    containers.homeassistant = {
      dependsOn = [ "zwave2mqtt" ];
      environment.TZ = config.time.timeZone;
      extraOptions = [ "--network=${network_name}" ];
      image = "ghcr.io/home-assistant/home-assistant:stable@sha256:526120826f55aeb712208db5964fc621ceb11cf192ecfd057794451b27c50457";
      volumes = [ "/persistence/home-assistant:/config" ];
    };

    containers.zwave2mqtt = {
      environment.TZ = config.time.timeZone;
      extraOptions = [ "--network=${network_name}" "--device=/dev/serial/by-id/usb-0658_0200-if00:/dev/zwave" ];
      image = "zwavejs/zwavejs2mqtt:latest@sha256:6ce9ecede861d937532153e5e47570f3c5669f9e93c12870279a5048a4e0686f";
      volumes = [ "/persistence/zwavejs2mqtt:/usr/src/app/store" ];
    };

    containers.signal-cli-rest-api = {
      image = "bbernhard/signal-cli-rest-api:latest@sha256:dd5365eabb0e70b791bf0ec00b087310efb2d75fbed9f58df56f7f2763aca913";
      extraOptions = [ "--network=${network_name}" ];
      environment.MODE = "json-rpc";
      volumes = [ "/persistence/signal-cli-rest-api:/home/.local/share/signal-cli" ];
    };
  };
}
