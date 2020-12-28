{ pkgs
, lib
, config
, kubernetes-ca
, etcd-ca
}:
let
  reqCsr = builtins.toJSON {
    CN = "system:kube-apiserver";
    hosts = config.localHosts
      ++ config.masterHosts
      ++ config.masterHostNames
      ++ config.advertiseIPs
      ++ config.advertiseHostNames
      ++ [
      "kubernetes"
      "kubernetes.default.svc"
      "kubernetes.default.svc.cluster.local"
      "10.0.0.1"
    ];
    inherit (config) key;
    names = lib.singleton config.name;
  };
in
pkgs.stdenvNoCC.mkDerivation {
  name = "certs-apiserver";
  buildInputs = with pkgs; [
    cfssl
  ];

  caConfigClient = pkgs.writeText "caConfig.json" config.caConfigClient;
  caConfigServer = pkgs.writeText "caConfig.json" config.caConfigServer;
  inherit reqCsr;

  phases = [ "buildPhase" "installPhase" ];

  buildPhase = ''
    echo "$reqCsr" | \
    cfssl gencert \
      -ca ${etcd-ca}/etcd.pem \
      -ca-key ${etcd-ca}/etcd-key.pem \
      -config "$caConfigClient" \
      - | \
    cfssljson -bare apiserver-etcd-client

    echo "$reqCsr" | \
    cfssl gencert \
      -ca ${kubernetes-ca}/kubernetes.pem \
      -ca-key ${kubernetes-ca}/kubernetes-key.pem \
      -config "$caConfigServer" \
      - | \
    cfssljson -bare apiserver

    echo "$reqCsr" | \
    cfssl gencert \
      -ca ${kubernetes-ca}/kubernetes.pem \
      -ca-key ${kubernetes-ca}/kubernetes-key.pem \
      -config "$caConfigClient" \
      - | \
    cfssljson -bare apiserver-kubelet-client

    echo "$reqCsr" | \
    cfssl gencert \
      -ca ${kubernetes-ca}/kubernetes.pem \
      -ca-key ${kubernetes-ca}/kubernetes-key.pem \
      -config "$caConfigClient" \
      - | \
    cfssljson -bare apiserver-proxy-client
  '';

  installPhase = ''
    mkdir -p $out/apiserver/
    cp *.pem $out/apiserver/
  '';
}
