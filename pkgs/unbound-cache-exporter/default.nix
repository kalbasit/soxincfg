{
  lib,
  python3,
  unbound,
  ...
}:

python3.pkgs.buildPythonApplication {
  pname = "unbound-cache-exporter";
  version = "1.0.0";

  src = ./src;

  propagatedBuildInputs = with python3.pkgs; [
    requests
    publicsuffixlist
    unbound
  ];

  # --- Enable Testing ---
  # Add the testing framework to the build environment.
  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
  ];

  # Set doCheck to true to tell Nix to run the tests.
  doCheck = true;

  format = "other";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp $src/unbound_cache_exporter.py $out/bin/unbound-cache-exporter
    chmod +x $out/bin/unbound-cache-exporter
    runHook postInstall
  '';

  meta = {
    description = "A script to export active domains from the Unbound cache using the Public Suffix List for filtering.";
    license = lib.licenses.mit;
    mainProgram = "unbound-cache-exporter";
    platforms = lib.lists.intersectLists python3.meta.platforms unbound.meta.platforms;
  };
}
