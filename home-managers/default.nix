inputs@{ ... }:

{
  coding-home = {
    modules = [
      ./coding-home/home.nix
      {
        home = {
          username = "user";
          homeDirectory = "/home/user";
stateVersion="24.05";
        };
      }
    ];

pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
  };
}
