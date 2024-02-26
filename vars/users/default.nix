inputs@{ ... }:

{ mode, lib }:

let
  inherit (lib)
    optionalAttrs
    ;
in
{
  yl =
    optionalAttrs (mode == "NixOS")
      {
        # Generate the password with the following command on Linux:
        # mkpasswd --method=SHA-512 | xargs -I{} sed -e 's:hashedPassword = ".*";:hashedPassword = "{}";:g' -i vars/users/default.nix
        hashedPassword = "$6$lAOktqm6B9gB0Xff$oSLoR.0Xz2461Y908gYN8tjQlCRnWUK/VgM7k8O7YSN.98RwSGj6FMn9CwYafeQG1uSIldw66f.YOtJSDzSQD0";

        sshKeys = [
          # YubiKey 5C
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+Pe+dPmFXssGgCYUmKwOHLL7gAlbvUxt64D0C8xL64GI+yjzOaF+zlXVkvpKpwwIwgUwtZLABTsgKfkzEzKZbIPEt9jn8eba/82mKF//TKup2dnpunfux6wMJQAQA/1m9tKtSFJOBbNXkZmtQ3Ewm4T/dJPOr7RnX/eyIIBrfJ9NQoMmSU8MJ8ii2V6nrFi1srZAHb5KVpSSSJJOM9jZs9DQ4FJ5YLTpDVG35KbrpSaYSgQwjnIajQI+yQmYF+/m7KofBgbjYTrZ71VgAjXXd/zXw+Z+kN/CyxDccd35oI/KlX5tIy/Qz3JIlHao1WWMM4cVN9dzJuGdFIi+QBsv2nOzNaCvCGdvguhhWLM1gaXGgVHasoZcNedPasteabg2GJjsQTbc82XXWLkAcDVhrRjvG2sfOTXskneDhZhahavrjs5LE8eq3JsfjVUCJLIK3YyS7T6vN6CAzv3y1r47sshjisG9b3E9L4MDZCKZ2YViaA+oHoEemxOC08m5SaGXJX8tt68MIP9pwva5ESZdwS9pbRjQg7QzIDg6nMRSgw/KleZ7g/vtk/5IxEVtK0vbhjFOjDfY8XzPXEYkxkxmsCytKoGnRFmtTHTNJ/vC0Dz6+KTwRJiF1ZjQzbFHEEo/scs82mx4EXxD6XnpPQkAHmQYTOloUevXX2zrx3rDbfQ== cardno:000609501258"

          # Onlykey
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAILJKaAMg2OSpXi7+B1oIqzKz1lQiEZPo0Xv6ty35uwzzAAAABHNzaDo= wael.nasreddine+onlykey_0@gmail.com"

          # Terminus Phone
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIuEPwgfiRDZ1+Ahc43NKSfScT97iS9ueK9lbrcDYJyh Aris-Termius"

          # ChromeOS 2023-08-24
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC0zNAx9dH6iKo+ZeCZmYjNYvr/9rLXZrNCpwD5eHZLuAsvT4J6u2Mv0+4zirXsyhW3QFXoAq8b0lCvOj8vG1JMFERQUrXE4mCQdPz7mMfTVPAbxKn9jWstfqWrTDTn5aGrKUQZNkEf3OwUIq7ilRpQC/R4qrWa/IfPHW6a3xgXfknwexZc7QQAPP/RZ/YkovLvzqJRZxnDOEESg7Is9+QrXhMskS3UFH3POxm0XCnIC2+onji7TXE4PUnWLTEztnPnKobBFWz2sBw65dAmqGSxo3x8kmQZNoPg8lQNiO0edsFpZrmt4M6dquZDlSaw+v+Qw8N3I5sSGS/57Dsz9fnWxxh8Vkl3WfANLUu4up2RhAzZKBjvAfJCD8Fm2ht2w37cVezjkysO+n8TwNYasmJsYpTz7L9565qHxqxGnKNzhytf5tq2R+fzHWjXH7KMtYVz+1oiBpYSb9DFpN6TA6qg4Qt7hcUXbfGVPT6Y+EizNEGpNpgUTmPC2bi8rYtbbiKkzC4eg4BR2nMkJLm/ppJtmM2UeL3GivmNHJ958geyFR33KnJYbYYVC5fS0b3mJhcAdZf9zDaljurv3fKwWgdqkQlWgK+RHm+5LmwYJHgUuAT9nmgdVWxF7H5sOQuiJBVxnCPMRtmpKVTKqFXMZvYMqI5f8z2Lr7POdSZh97HxLw== ChromeOS 2023-08-24"
        ];

        uid = 2000;

        isAdmin = true;
        isNixTrustedUser = true;

        home = "/yl";
      }

    // optionalAttrs (mode == "nix-darwin")
      {
        home = "/Users/yl";
      }
  ;
}
