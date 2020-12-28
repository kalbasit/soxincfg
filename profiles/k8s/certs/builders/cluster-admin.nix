{ pkgs
, lib
, config
, kubernetes-ca
}:
let
  reqCsr = builtins.toJSON {
    CN = "cluster-admin";
    hosts = [ "cluster-admin" ];
    inherit (config) key;
    names = [{
      O = "system:masters";
    }];
  };
in
pkgs.stdenvNoCC.mkDerivation {
  name = "certs-cluster-admin";
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
    cfssljson -bare cluster-admin
  '';

  installPhase = ''
    mkdir -p $out/cluster-admin/
    cp *.pem $out/cluster-admin/
  '';
}
