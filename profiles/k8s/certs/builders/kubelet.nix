{ pkgs
, lib
, config
, kubernetes-ca
}:
let
  reqCsr = host: builtins.toJSON {
    CN = host;
    hosts = config.localHosts ++ config.masterHosts ++ config.masterHostNames ++ config.advertiseIPs ++ config.advertiseHostNames ++ config.workerHosts ++ config.workerHostNames;
    inherit (config) key;
    names = [{ }];
  };

  reqCsrApiserverClient = host: builtins.toJSON {
    CN = "system:node:${host}";
    hosts = map (x: "system:node:${x}") (config.localHosts ++ config.masterHosts ++ config.masterHostNames ++ config.advertiseIPs ++ config.advertiseHostNames ++ config.workerHosts ++ config.workerHostNames);
    inherit (config) key;
    names = [{
      O = "system:nodes";
    }];
  };

  hosts = config.masterHostNames ++ config.workerHostNames;
in
pkgs.stdenvNoCC.mkDerivation {
  name = "certs-kubelet";
  buildInputs = with pkgs; [
    cfssl
  ];

  caConfigServer = pkgs.writeText "caConfig.json" config.caConfigServer;
  caConfigClient = pkgs.writeText "caConfig.json" config.caConfigClient;

  phases = [ "buildPhase" "installPhase" ];

  buildPhase = lib.concatMapStringsSep "\n"
    (host:
      let
        req = reqCsr host;
        reqApiserverClient = reqCsrApiserverClient host;
      in
      ''
        echo '${req}' | \
        cfssl gencert \
          -ca ${kubernetes-ca}/kubernetes.pem \
          -ca-key ${kubernetes-ca}/kubernetes-key.pem \
          -config "$caConfigServer" \
          - | \
        cfssljson -bare ${host}-kubelet

        echo '${reqApiserverClient}' | \
        cfssl gencert \
          -ca ${kubernetes-ca}/kubernetes.pem \
          -ca-key ${kubernetes-ca}/kubernetes-key.pem \
          -config "$caConfigClient" \
          - | \
        cfssljson -bare ${host}-kubelet-apiserver-client
      '')
    hosts;

  installPhase = ''
    mkdir -p $out/kubelet/
    cp *.pem $out/kubelet/
  '';
}
