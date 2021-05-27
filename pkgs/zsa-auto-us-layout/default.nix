# This derivation was build based on these resources:
# - https://askubuntu.com/a/337431/11272
# - https://superuser.com/a/350336/29825
# - https://github.com/zsa/wally/tree/master/dist/linux64

{ stdenvNoCC, lib, ... }:

stdenvNoCC.mkDerivation {
  pname = "zsa-auto-us-layout";
  version = "1.0.0";

  # it only installs files
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;
  unpackPhase = ":";

  src = ./src;

  installPhase = ''
    mkdir -p $out/lib/udev/rules.d
    substitute $sourceRoot/60-zsa-auto-us-layout.rules $out/lib/udev/rules.d/ \
      --subst-var-by out $out
  '';
}
