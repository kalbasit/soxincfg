{
  config,
  lib,
  mode,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf optionalAttrs;
in
optionalAttrs (mode == "home-manager") {
  home.activation.sops-nix-post = mkIf (config.sops.secrets != { }) (
    lib.hm.dag.entryAfter [ "sops-nix" ] ''
      # wait few seconds before we start
      noteEcho "Waiting for secrets to show up"
      sleep 3

      runPost() {
        local _sops_secretsPath="$1"
        local _sh

        if [[ "$(find "$_sops_secretsPath/" -name "_aws_configure_profile_*_sh" | wc -l)" -gt 0 ]]; then
          for _sh in "$_sops_secretsPath"/_aws_configure_profile_*_sh; do
            # run it in a subshell but only if it's executable
            if [[ -x $_sh ]]; then
              noteEcho "Running the post script $_sh"
              (PATH=${pkgs.awscli2}/bin:$PATH exec $_sh)
            else
              warnEcho "$_sh is not executable, skipping it."
            fi
          done
        else
          warnEcho "No aws configure profile were found"
        fi

        if [[ "$(find "$_sops_secretsPath/" -name "_kube_configure_profile_*_sh" | wc -l)" -gt 0 ]]; then
          for _sh in "$_sops_secretsPath"/_kube_configure_profile_*_sh; do
            # run it in a subshell but only if it's executable
            if [[ -x $_sh ]]; then
              noteEcho "Running the post script $_sh"
              (exec $_sh)
            else
              warnEcho "$_sh is not executable, skipping it."
            fi
          done
        else
          warnEcho "No kube configure profile were found"
        fi
      }

      _secrets_found=0
      if [[ -d "/run/secrets" ]]; then
        _secrets_found=1
        noteEcho "Running the SOPS Post function for /run/secrets"
        runPost "/run/secrets"
      fi

      if [[ -d "${config.xdg.configHome}/sops-nix/secrets" ]]; then
        _secrets_found=1
        noteEcho "Running the SOPS Post function for ${config.xdg.configHome}/sops-nix/secrets"
        runPost "${config.xdg.configHome}/sops-nix/secrets"
      fi

      if [[ $_secrets_found -eq 0 ]]; then
        warnEcho "No secrets were found"
      fi
    ''
  );
}
