{ pkgs
, lib
, config
, etcd-ca
, dirPrefix ? ""
}:
let
  reqCsrHost = builtins.toJSON {
    CN = "etcd.${config.domain}";
    inherit (config) key;
    names = lib.singleton config.name;
    hosts = config.localHosts ++ config.masterHosts ++ config.masterHostNames;
  };
  reqCsrPeer = builtins.toJSON {
    CN = "etcd-peers.${config.domain}";
    inherit (config) key;
    names = lib.singleton config.name;
    hosts = config.localHosts ++ config.masterHosts ++ config.masterHostNames;
  };
in
pkgs.stdenvNoCC.mkDerivation {
  name = "certs-etcd";
  buildInputs = with pkgs; [
    cfssl
  ];

  caConfig = pkgs.writeText "caConfig.json" config.caConfigServerClient;
  inherit reqCsrHost reqCsrPeer;

  phases = [ "buildPhase" "installPhase" ];

  buildPhase = (lib.concatMapStringsSep "\n"
    (host: ''
      echo "$reqCsrHost" | \
      cfssl gencert \
        -ca ${etcd-ca}/etcd.pem \
        -ca-key ${etcd-ca}/etcd-key.pem \
        -config "$caConfig" \
        - | \
      cfssljson -bare ${host}

      echo "$reqCsrPeer" | \
      cfssl gencert \
        -ca ${etcd-ca}/etcd.pem \
        -ca-key ${etcd-ca}/etcd-key.pem \
        -config "$caConfig" \
        - | \
      cfssljson -bare peer-${host}
    '')
    config.masterHostNames);

  installPhase = ''
    mkdir -p $out/${dirPrefix}
    cp *.pem $out/${dirPrefix}
  '';
}
