{ pkgs
, lib
, config
, etcd-ca
}:
let
  reqCsr = builtins.toJSON {
    CN = "etcd-healthcheck-client";
    hosts = [ "etcd-healthcheck-client" ];
    inherit (config) key;
    names = [{ }];
  };
in
pkgs.stdenvNoCC.mkDerivation {
  name = "certs-etcd-healthcheck-client";
  buildInputs = with pkgs; [
    cfssl
  ];

  caConfig = pkgs.writeText "caConfig.json" config.caConfigClient;
  inherit reqCsr;

  phases = [ "buildPhase" "installPhase" ];

  buildPhase = ''
    echo "$reqCsr" | \
    cfssl gencert \
      -ca ${etcd-ca}/etcd.pem \
      -ca-key ${etcd-ca}/etcd-key.pem \
      -config "$caConfig" \
      - | \
    cfssljson -bare etcd-healthcheck-client
  '';

  installPhase = ''
    mkdir -p $out/etcd-healthcheck-client/
    cp *.pem $out/etcd-healthcheck-client/
  '';
}
