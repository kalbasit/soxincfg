{ pkgs
, lib
, config
, kubernetes-ca
}:
let
  reqCsr = builtins.toJSON {
    CN = "system:kube-scheduler";
    hosts = [ "system:kube-scheduler" ];
    inherit (config) key;
    names = [{ }];
  };
in
pkgs.stdenvNoCC.mkDerivation {
  name = "certs-scheduler";
  buildInputs = with pkgs; [
    cfssl
  ];

  caConfig = pkgs.writeText "caConfig.json" config.caConfigClient;
  inherit reqCsr;

  phases = [ "buildPhase" "installPhase" ];

  buildPhase = ''
    echo "$reqCsr" | \
    cfssl gencert \
      -ca ${kubernetes-ca}/kubernetes.pem \
      -ca-key ${kubernetes-ca}/kubernetes-key.pem \
      -config "$caConfig" \
      - | \
    cfssljson -bare scheduler-apiserver-client
  '';

  installPhase = ''
    mkdir -p $out/scheduler/
    cp *.pem $out/scheduler/
  '';
}
