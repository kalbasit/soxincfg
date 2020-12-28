{ pkgs
, lib
, name ? "ca"
, dirPrefix ? ""
, config
}:
let
  caCsr = builtins.toJSON {
    CN = "${name}.${config.domain}";
    inherit (config) key;
    names = lib.singleton config.name;
  };
in
pkgs.stdenvNoCC.mkDerivation {
  inherit name;
  buildInputs = with pkgs; [
    cfssl
  ];

  inherit caCsr;

  phases = [ "buildPhase" "installPhase" ];

  buildPhase = ''
    echo "$caCsr" | cfssl gencert -initca - | cfssljson -bare ${name}
  '';

  installPhase = ''
    mkdir -p $out/${dirPrefix}
    cp *.pem $out/${dirPrefix}
  '';
}
