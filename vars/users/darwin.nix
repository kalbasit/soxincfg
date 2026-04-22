userName:

{
  "${userName}" = {
    home = "/Users/${userName}";

    sshKeys = import ./ssh-keys.nix;
  };
}
