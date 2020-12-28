{ pkgs
, lib
, config
, kubernetes-ca
}:
let
  reqCsr = builtins.toJSON {
    CN = "kube-controller-manager";
    hosts = [ "kube-controller-manager" ];
    inherit (config) key;
    names = [{ }];
  };

  reqCsrApiserverClient = builtins.toJSON {
    CN = "system:kube-controller-manager";
    hosts = [ "system:kube-controller-manager" ];
    inherit (config) key;
    names = [{ }];
  };
in
pkgs.stdenvNoCC.mkDerivation {
  name = "certs-controller-manager";
  buildInputs = with pkgs; [
    cfssl
  ];

  caConfigServer = pkgs.writeText "caConfig.json" config.caConfigServer;
  caConfigClient = pkgs.writeText "caConfig.json" config.caConfigClient;
  inherit reqCsr reqCsrApiserverClient;

  phases = [ "buildPhase" "installPhase" ];

  buildPhase = ''
    echo "$reqCsr" | \
    cfssl gencert \
      -ca ${kubernetes-ca}/kubernetes.pem \
      -ca-key ${kubernetes-ca}/kubernetes-key.pem \
      -config "$caConfigServer" \
      - | \
    cfssljson -bare controller-manager

    echo "$reqCsrApiserverClient" | \
    cfssl gencert \
      -ca ${kubernetes-ca}/kubernetes.pem \
      -ca-key ${kubernetes-ca}/kubernetes-key.pem \
      -config "$caConfigClient" \
      - | \
    cfssljson -bare controller-manager-apiserver-client
  '';

  installPhase = ''
    mkdir -p $out/controller-manager/
    cp *.pem $out/controller-manager/
  '';
}
