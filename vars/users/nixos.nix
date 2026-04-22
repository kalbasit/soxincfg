userName:

{
  "${userName}" = {
    # Generate the password with the following command on Linux:
    # mkpasswd --method=SHA-512 | xargs -I{} sed -e 's:hashedPassword = "[^"]\{10,\}";:hashedPassword = "{}";:g' -i vars/users/default.nix
    hashedPassword = "$6$6jR0WhIP1DmSf67S$qc9of0VxV8GD3dF2DYYohssfU1AB.AJ5EXIVVctAttW.E7Ri6PIgzM3FFE95vr.xfhXxManypBto8fZoJzq8a1";

    sshKeys = import ./ssh-keys.nix;

    uid = 2000;

    isAdmin = true;
    isNixTrustedUser = true;

    home = "/home/${userName}";
  };
}
