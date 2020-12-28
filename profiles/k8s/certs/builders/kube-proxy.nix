{ pkgs
, lib
, config
, kubernetes-ca
}:
let
  reqCsr = builtins.toJSON {
    CN = "system:kube-proxy";
    hosts = [ "system:kube-proxy" ];
    inherit (config) key;
    names = [{ }];
  };
in
pkgs.stdenvNoCC.mkDerivation {
  name = "certs-kube-proxy";
  buildInputs = with pkgs; [
    cfssl
  ];

  caConfigClient = pkgs.writeText "caConfig.json" config.caConfigClient;
  inherit reqCsr;

  phases = [ "buildPhase" "installPhase" ];

  buildPhase = ''
    echo "$reqCsr" | \
    cfssl gencert \
      -ca ${kubernetes-ca}/kubernetes.pem \
      -ca-key ${kubernetes-ca}/kubernetes-key.pem \
      -config "$caConfigClient" \
      - | \
    cfssljson -bare kube-proxy-apiserver-client
  '';

  installPhase = ''
    mkdir -p $out/kube-proxy/
    cp *.pem $out/kube-proxy/
  '';
}
