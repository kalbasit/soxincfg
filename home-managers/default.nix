inputs:

{
  coding-home = {
    inherit inputs;

    modules = [
      ./coding-home/home.nix
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
