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

      postScriptChecksumContent() {
        ${pkgs.coreutils}/bin/sha256sum "$1" | ${pkgs.gawk}/bin/awk '{print $1}' | ${pkgs.coreutils}/bin/tr -d '\n'
      }

      postScriptChecksumName() {
        echo -n "$1" | ${pkgs.coreutils}/bin/sha256sum | ${pkgs.gawk}/bin/awk '{print $1}' | ${pkgs.coreutils}/bin/tr -d '\n'
      }

      recordLastPostScriptExecChecksum() {
        local _sh="$1"
        local _store="''${HOME}/.local/share/home-manager-sops-nix-post"
        local _exec_path="$_store/$(postScriptChecksumName "$_sh")"

        mkdir -p "$_store"
        postScriptChecksumContent "$_sh" > "$_exec_path"
      }

      getLastPostScriptExecChecksum() {
        local _sh="$1"
        local _store="''${HOME}/.local/share/home-manager-sops-nix-post"
        local _exec_path="$_store/$(postScriptChecksumName "$_sh")"

        if [[ -f "$_exec_path" ]]; then
          cat "$_exec_path"
        else
          echo -n "invalid-checksum"
        fi
      }

      runPostScript() {
        local _sh="$1"

        if [[ -x $_sh ]]; then
          if [[ "$(getLastPostScriptExecChecksum "$_sh")" != "$(postScriptChecksumContent "$_sh")" ]]; then
            noteEcho "Running the post script $_sh"
            (PATH=${pkgs.awscli2}/bin:$PATH exec $_sh)
            recordLastPostScriptExecChecksum "$_sh"
          else
            warnEcho "$_sh has not changed since last exec, skipping it."
          fi
        else
          warnEcho "$_sh is not executable, skipping it."
        fi
      }

      runPostAWS() {
        local _sops_secretsPath="$1"
        local _sh

        if [[ "$(find "$_sops_secretsPath/" -name "_aws_configure_profile_*_sh" | wc -l)" -gt 0 ]]; then
          for _sh in "$_sops_secretsPath"/_aws_configure_profile_*_sh; do
            runPostScript "$_sh"
          done
        else
          warnEcho "No aws configure profile were found"
        fi
      }

      runPostKubernetes() {
        local _sops_secretsPath="$1"
        local _sh

        if [[ "$(find "$_sops_secretsPath/" -name "_kube_configure_profile_*_sh" | wc -l)" -gt 0 ]]; then
          for _sh in "$_sops_secretsPath"/_kube_configure_profile_*_sh; do
            runPostScript "$_sh"
          done
        else
          warnEcho "No kube configure profile were found"
        fi
      }

      runPostForSecrets() {
        noteEcho "Running the SOPS Post function for $1"

        runPostAWS "$1"
        runPostKubernetes "$1"
      }

      runPost() {
        local secrets_found=0
        local secrets_dirs=("/run/secrets" "${config.xdg.configHome}/sops-nix/secrets")

        for secret_dir in "''${secrets_dirs[@]}"; do
          if [[ -d "$secret_dir" ]]; then
            secrets_found=1
            runPostForSecrets "$secret_dir"
          fi
        done

        if [[ $secrets_found -eq 0 ]]; then
          warnEcho "No secrets were found"
        fi
      }

      runPost
    ''
  );
}
