{ autoPatchelfHook, fetchurl, stdenv }:

stdenv.mkDerivation rec {
  pname = "qb64";
  version = "1.4";

  src = fetchurl {
    url = "https://github.com/QB64Team/${pname}/releases/download/v${version}/qb64_${version}_lnx.tar.gz";
    sha256 = "0000000000000000000000000000000000000000000000000000000000000000";
  }

  nativeBuildInputs = [ autoPatchelfHook ];
}
