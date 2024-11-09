{ ... }:

{
    # Configure SOPS to use the gpg wrapper
    # https://github.com/getsops/sops#213specify-a-different-gpg-executable
  home.sessionVariables."SOPS_GPG_EXEC" ="qubes-gpg-client";
  sops.environment.SOPS_GPG_EXEC ="qubes-gpg-client";
  sops.environment.QUBES_GPG_DOMAIN="vault-gpg";
  sops.gnupg.home="/dev/null";

  sops.secrets.hello = { sopsFile = ./secrets.sops.yaml; };
}
