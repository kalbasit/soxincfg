{ ... }:

{
  home.sessionVariables = {
    # Configure SOPS to use the gpg wrapper
    # https://github.com/getsops/sops#213specify-a-different-gpg-executable
    SOPS_GPG_EXEC="qubes-gpg-client";
  };
}
