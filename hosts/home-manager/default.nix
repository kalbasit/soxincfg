{ lib
, nur
, pkgset
, self
, soxin
, system
, ...
}@args:
with lib;
let
  buildHosts = hostPaths:
    builtins.builtins.listToAttrs (
      map (path: nameValuePair (lists.last (splitString "/" path)) (homeManagerConfiguration path)) hostPaths
    );

  homeManagerConfiguration = path:
    let
      # This allows you to have sub-folders to order cnofigurations inside the
      # hosts folder.
      hostName = lists.last (splitString "/" path);

      flakeModules = builtins.attrValues (removeAttrs self.nixosModules [ "profiles" ]);
    in
    soxin.lib.homeManagerConfiguration rec{
      inherit system;
      inherit (pkgset) pkgs;

      homeDirectory = "/home/yl";
      username = "yl";
      configuration = path + "/home.nix";
      hmSpecialArgs = { soxincfg = self; };
      hmModules =
        let
          flakeModules = builtins.attrValues (removeAttrs self.nixosModules [ "profiles" ]);
        in
        lib.concat flakeModules [
          self.nixosModules.profiles.core
          { nixpkgs.overlays = [ nur.overlay soxin.overlay self.overlay self.overrides.${system} ]; }
        ];
    };
in
if system == "x86_64-linux" then
  import ./x86-64 { inherit buildHosts; }
else if system == "aarch64-linux" then
  import ./aarch64-linux { inherit buildHosts; }
else builtins.trace "I don't have any hosts buildable for the system ${system}" [ ]
