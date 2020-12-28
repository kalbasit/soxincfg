{ pkgs
, lib
, config
, etcd-ca
}:
let
  reqCsr = builtins.toJSON {
    CN = "cilium-client";
    hosts = [ "cilium-client" ];
    inherit (config) key;
    names = [{ }];
  };
in
pkgs.stdenvNoCC.mkDerivation {
  name = "certs-cilium";
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
    cfssljson -bare cilium-etcd-client
  '';

  installPhase = ''
    mkdir -p $out/cilium/
    cp *.pem $out/cilium/
  '';
}
