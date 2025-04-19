{
  config,
  ...
}:

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
      let
        dockercli = "${config.virtualisation.docker.package}/bin/docker";
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

    containers.postgres = {
      environment = {
        PGDATA = "/var/lib/postgresql/data";
        POSTGRES_PASSWORD_FILE = "/run/secrets/postgres-passwd";
      };
      extraOptions = [
        "--health-cmd=pg_isready -U postgres --dbname=postgres"
        "--health-interval=10s"
        "--health-timeout=5s"
        "--health-start-period=30s"
        "--network=${network_name}"
        "--shm-size=1G"
      ];
      image = "postgres:16.1-alpine";
      ports = [ "5432:5432" ];
      volumes = [
        "/persistence/postgres/data:/var/lib/postgresql/data"
        "/persistence/postgres/postgres-passwd:/run/secrets/postgres-passwd:ro"
      ];
    };

  };
}
