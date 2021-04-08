pkgs-master:

final: prev: {
  inherit (pkgs-master) nixpkgs-fmt starship terraform terraform-providers firefox tailscale bazel;

  jetbrains = pkgs-master.jetbrains // {
    idea-ultimate = pkgs-master.jetbrains.idea-ultimate.overrideAttrs(oa: rec {
      name = "idea-ultimate-${version}";
      version = "2020.2.4";
      src = prev.fetchurl {
        url = "https://download.jetbrains.com/idea/ideaIU-${version}-no-jbr.tar.gz";
        sha256 = "sha256-/pYbEN7vExfgXEuQy+Sc97h2HzxPlJ3im7VjraJEGRc=";
      };
    });
  };
}
