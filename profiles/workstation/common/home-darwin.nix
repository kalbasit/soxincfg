{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "gsed" ''
      exec ${pkgs.gnused}/bin/sed "$@"
    '')
  ];
}
