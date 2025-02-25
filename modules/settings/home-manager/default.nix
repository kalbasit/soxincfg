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
      isDarwin() {
        local _os="$(uname -s)"
        [[ "''${_os}" == "Darwin" ]]
      }

      isLinux() {
        local _os="$(uname -s)"
        [[ "''${_os}" == "Linux" ]]
      }

      # wait few seconds before we start
      noteEcho "Waiting for secrets to show up"
      sleep 3

      if isLinux; then
        _sops_secretsPath="/run/secrets"
      elif isDarwin; then
        _sops_secretsPath="${config.xdg.configHome}/sops-nix/secrets"
      else
        warnEcho "SOPS Nix Post: OS is not supported"
        exit 1
      fi

      runPost() {
        local _sh

        if [[ "$(find "$_sops_secretsPath/" -name "_aws_configure_profile_*_sh" | wc -l)" -gt 0 ]]; then
          for _sh in "$_sops_secretsPath"/_aws_configure_profile_*_sh; do
            # run it in a subshell but only if it's executable
            if [[ -x $_sh ]]; then
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
              (exec $_sh)
            else
              warnEcho "$_sh is not executable, skipping it."
            fi
          done
        else
          warnEcho "No kube configure profile were found"
        fi
      }

      if [[ -d "$_sops_secretsPath" ]]; then
        runPost
      else
        warnEcho "No secrets were found"
      fi
    ''
  );
}
