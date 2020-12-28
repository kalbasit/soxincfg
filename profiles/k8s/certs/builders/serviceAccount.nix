{ pkgs
, lib
, config
, kubernetes-ca
}:
let
  reqCsr = builtins.toJSON {
    CN = "serviceaccount.k8s.fsn.lama-corp.space";
    hosts = config.localHosts ++ config.masterHosts ++ config.masterHostNames ++ config.advertiseIPs ++ config.advertiseHostNames;
    inherit (config) key;
    names = lib.singleton (
      lib.recursiveUpdate config.name { CN = "system:service-account-signer"; }
    );
  };
in
pkgs.stdenvNoCC.mkDerivation {
  name = "certs-service-account";
  buildInputs = with pkgs; [
    cfssl
  ];

  caConfig = pkgs.writeText "caConfig.json" config.caConfigServerClient;
  inherit reqCsr;

  phases = [ "buildPhase" "installPhase" ];

  buildPhase = ''
    echo "$reqCsr" | \
    cfssl gencert \
      -ca ${kubernetes-ca}/kubernetes.pem \
      -ca-key ${kubernetes-ca}/kubernetes-key.pem \
      -config "$caConfig" \
      - | \
    cfssljson -bare service-account
  '';

  installPhase = ''
    mkdir -p $out/service-account/
    cp *.pem $out/service-account/
  '';
}
