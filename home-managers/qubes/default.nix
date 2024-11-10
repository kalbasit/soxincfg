inputs:

{
  code-template = {
    inherit inputs;

    modules = [
      ./code-template/home.nix
      {
        home = {
          username = "user";
          homeDirectory = "/home/user";
          stateVersion = "24.05";
        };
      }
    ];

    system = "x86_64-linux";
  };
}
