let
  tz = "America/Los_Angeles";
in {
  services.zwavejs2mqtt = {
    service.image = "zwavejs/zwavejs2mqtt:latest@sha256:6ce9ecede861d937532153e5e47570f3c5669f9e93c12870279a5048a4e0686f";
    service.volumes = [ "/persistence/zwavejs2mqtt:/usr/src/app/store" ];
    service.environment.TZ = tz;
    service.ports = ["8091:8091" "3000:3000"];
    service.devices = [
       "/dev/serial/by-id/usb-0658_0200-if00:/dev/zwave"
    ];
    service.restart = "unless-stopped";
  };

  services.homeassistant = {
    service.image = "ghcr.io/home-assistant/home-assistant:stable@sha256:526120826f55aeb712208db5964fc621ceb11cf192ecfd057794451b27c50457";
    service.volumes = [ "/persistence/home-assistant:/config" ];
    service.environment.TZ = tz;
    service.ports = ["8123:8123"];
    service.depends_on = ["zwavejs2mqtt"];
    service.restart = "unless-stopped";
  };

  services.nginx-proxy-manager = {
    service.image = "docker.io/jc21/nginx-proxy-manager@sha256:0a9d4155c6b3b453149fc48aadb561227d0f79bddb97004aea50c51cd1995e13";
    service.volumes = [
      "/persistence/nginx-proxy-manager/data:/data"
      "/persistence/nginx-proxy-manager/letsencrypt:/etc/letsencrypt"
    ];
    service.ports = [ "80:80" "81:81" "443:443" ];
    service.restart = "unless-stopped";

    service.depends_on = ["homeassistant"];
  };

  # services.unifi = {
  #   service.image = "docker.io/linuxserver/unifi-controller@sha256:a6593f8105ed1ff8230d372c677248ae503069722d7791b17e3c9c322980018b";
  #   service.volumes = [
  #     "/persistence/unifi:/config"
  #   ];
  #   service.environment = {
  #      PUID="1000";
  #      PGID="1000";
  #      MEM_LIMIT="1024"; #optional
  #      MEM_STARTUP="1024"; #optional
  #   };
  #   service.ports = [
  #      "3478:3478/udp" # Unifi STUN port
  #      "10001:10001/udp" # Required for AP discovery
  #      "8080:8080" # Required for device communication
  #      "8443:8443" # Unifi web admin port
  #      # "1900:1900/udp" # Required for `Make controller discoverable on L2 network` option
  #      # "8843:8843" # for guest portal, HTTPS
  #      # "8880:8880" # for guest portal, HTTP
  #      "6789:6789" # For mobile throughput test
  #      "5514:5514/udp" # Remote syslog port
  #   ];
  #   service.restart = "unless-stopped";
  #
  #   service.depends_on = ["homeassistant"];
  # };
}
