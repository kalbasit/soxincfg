{ pkgs, lib, ... }:

{
  services.keepalived = {
    enable = true;
    extraGlobalDefs = ''
      lvs_id haproxy_DH
    '';
    vrrpScripts = {
      "check_haproxy" = {
        script = "${pkgs.killall}/bin/killall -0 haproxy";
        interval = 3;
        user = "root";
      };
      "check_apiserver" = {
        script = toString (pkgs.writeShellScript "check_apiserver.sh" ''
          errorExit() {
              echo "*** $*" 1>&2
              exit 1
          }

          ${lib.getBin pkgs.curl}/bin/curl \
            --silent \
            --max-time 2 \
            --insecure \
            https://localhost:6443/ \
            -o /dev/null || \
          errorExit "Error GET https://localhost:6443/"

          if ${pkgs.iproute}/bin/ip addr | ${pkgs.gnugrep}/bin/grep -q 172.28.7.10; then
            ${lib.getBin pkgs.curl}/bin/curl \
              --silent \
              --max-time 2 \
              --insecure \
              https://172.28.7.10:6443/ \
              -o /dev/null || \
            errorExit "Error GET https://172.28.7.10:6443/"
          fi
        '');
        interval = 3;
        weight = -2;
        fall = 10;
        rise = 2;
      };
    };
    vrrpInstances."VI_01" = {
      state = "BACKUP";
      interface = "ens3";
      virtualRouterId = 4;
      priority = 100;
      virtualIps = [{
        addr = "172.28.7.10/24";
      }];
      trackScripts = [
        "check_apiserver"
        "check_haproxy"
      ];
    };
  };
}
