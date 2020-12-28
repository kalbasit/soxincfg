{ pkgs
, lib
, config
, kubernetes-ca
}:
let
  reqCsr = builtins.toJSON {
    CN = "system:kube-addon-manager";
    hosts = [ "system:kube-addon-manager" ];
    inherit (config) key;
    names = [{ }];
  };
in
pkgs.stdenvNoCC.mkDerivation {
  name = "certs-addon-manager";
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
    cfssljson -bare addon-manager-apiserver-client
  '';

  installPhase = ''
    mkdir -p $out/addon-manager/
    cp *.pem $out/addon-manager/
  '';
}
