{ ... }:

{
  networking.firewall.allowedTCPPorts = [ 6443 ];

  services.haproxy = {
    enable = true;
    config = ''
        # global configuration is above
        log /dev/log local0
        log /dev/log local1 notice

      defaults
        mode http
        log global
        option httplog
        option dontlognull
        option http-server-close
        option forwardfor except 127.0.0.0/8
        option redispatch
        retries 1
        timeout http-request 10s
        timeout queue 20s
        timeout connect 5s
        timeout client 20s
        timeout server 20s
        timeout http-keep-alive 10s
        timeout check 10s

      backend api-server
        option httpchk GET /healthz
        http-check expect status 200
        mode tcp
        option ssl-hello-chk
        balance roundrobin
        server master-11-apiserver master-11.k8s.fsn.lama-corp.space:6443 check
        server master-12-apiserver master-12.k8s.fsn.lama-corp.space:6443 check
        server master-13-apiserver master-13.k8s.fsn.lama-corp.space:6443 check

      frontend api-server
        bind 172.28.7.10:6443
        mode tcp
        option tcplog
        use_backend api-server
    '';
  };
}
