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

  };
}
