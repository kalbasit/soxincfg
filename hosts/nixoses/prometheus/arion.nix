{ config, pkgs, lib, ... }:

let
  inherit (lib)
    mkForce
    ;
in
{
  environment.systemPackages = [
    pkgs.arion
  ];

  # Arion works with Docker, but for NixOS-based containers, you need Podman
  # since NixOS 21.05.
  virtualisation.docker.enable = mkForce false;
  virtualisation.podman.enable = true;
  virtualisation.podman.dockerCompat = true;
  virtualisation.podman.dockerSocket.enable = true;
  virtualisation.podman.defaultNetwork.dnsname.enable = true;

  soxincfg.settings.users.groups = [ "podman" ];

  systemd.services.arion_web_network =
      let
        compose-file=pkgs.runCommand "arion_web_network-compose.yaml" { } ''
          mkdir arion_web_network
          cd arion_web_network
          ${pkgs.arion}/bin/arion cat > $out
        '';
      in
    {
    after = ["podman.socket"];
    requires = [ "podman.socket" ];
    wantedBy = [ "multi-user.target" ];
    stopIfChanged = true; # Required because the wrapper file is kept as a state
    # TODO: can't run nix-build neither in systemd nor in a Nix build. Fix this
    # https://docs.hercules-ci.com/hercules-ci-effects/reference/nix-functions/runarion/
    # script = "${pkgs.docker-compose}/bin/docker-compose --file ${compose-file} up";
    preStart = "${pkgs.docker-compose}/bin/docker-compose --project-name arion_web_network --file ${./docker-compose.json} up --remove-orphans --no-start";
    script = "${pkgs.docker-compose}/bin/docker-compose --project-name arion_web_network --file ${./docker-compose.json} up";
    preStop = "${pkgs.docker-compose}/bin/docker-compose --project-name arion_web_network --file ${./docker-compose.json} stop --timeout 60";
  };
}
