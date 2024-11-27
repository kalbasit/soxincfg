inputs@{ ... }:

{ mode, lib }:

let
  inherit (lib) optionalAttrs;
in
{
  yl =
    optionalAttrs (mode == "NixOS") {
      # Generate the password with the following command on Linux:
      # mkpasswd --method=SHA-512 | xargs -I{} sed -e 's:hashedPassword = "[^"]\{10,\}";:hashedPassword = "{}";:g' -i vars/users/default.nix
      hashedPassword = "$6$6jR0WhIP1DmSf67S$qc9of0VxV8GD3dF2DYYohssfU1AB.AJ5EXIVVctAttW.E7Ri6PIgzM3FFE95vr.xfhXxManypBto8fZoJzq8a1";

      sshKeys = [
        # YubiKey 5C
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+Pe+dPmFXssGgCYUmKwOHLL7gAlbvUxt64D0C8xL64GI+yjzOaF+zlXVkvpKpwwIwgUwtZLABTsgKfkzEzKZbIPEt9jn8eba/82mKF//TKup2dnpunfux6wMJQAQA/1m9tKtSFJOBbNXkZmtQ3Ewm4T/dJPOr7RnX/eyIIBrfJ9NQoMmSU8MJ8ii2V6nrFi1srZAHb5KVpSSSJJOM9jZs9DQ4FJ5YLTpDVG35KbrpSaYSgQwjnIajQI+yQmYF+/m7KofBgbjYTrZ71VgAjXXd/zXw+Z+kN/CyxDccd35oI/KlX5tIy/Qz3JIlHao1WWMM4cVN9dzJuGdFIi+QBsv2nOzNaCvCGdvguhhWLM1gaXGgVHasoZcNedPasteabg2GJjsQTbc82XXWLkAcDVhrRjvG2sfOTXskneDhZhahavrjs5LE8eq3JsfjVUCJLIK3YyS7T6vN6CAzv3y1r47sshjisG9b3E9L4MDZCKZ2YViaA+oHoEemxOC08m5SaGXJX8tt68MIP9pwva5ESZdwS9pbRjQg7QzIDg6nMRSgw/KleZ7g/vtk/5IxEVtK0vbhjFOjDfY8XzPXEYkxkxmsCytKoGnRFmtTHTNJ/vC0Dz6+KTwRJiF1ZjQzbFHEEo/scs82mx4EXxD6XnpPQkAHmQYTOloUevXX2zrx3rDbfQ== cardno:000609501258"

        # Onlykey
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAILJKaAMg2OSpXi7+B1oIqzKz1lQiEZPo0Xv6ty35uwzzAAAABHNzaDo= wael.nasreddine+onlykey_0@gmail.com"

        # Terminus Phone
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIuEPwgfiRDZ1+Ahc43NKSfScT97iS9ueK9lbrcDYJyh Aris-Termius"

        # Cronus - ChromeOS 2024-10-23
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHDMWCJ+hjoFsZdUzOzlQ1xZKngq/OnoBflf3fsemK4s Cronus - ChromeOS 2024-10-23"

        # Hercules - Qubes Vault
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILWRLQQGw8+4ubG+113iHDfR08Wf6MJBCErjwfYxDvgZ Hercules - Qubes Vault"
      ];

      uid = 2000;

      isAdmin = true;
      isNixTrustedUser = true;

      home = "/home/yl";
    }

    // optionalAttrs (mode == "nix-darwin") { home = "/Users/yl"; };
}
