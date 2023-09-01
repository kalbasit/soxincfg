{ config, lib, mode, pkgs, ... }:

let
  inherit (lib)
    mkIf
    optionalAttrs
    ;
in
optionalAttrs (mode == "home-manager") {
  home.activation.aws-credentials = mkIf (config.sops.secrets != { }) (
    lib.hm.dag.entryAfter [ "setupLaunchAgents" ] ''
      isDarwin() {
        local _soxin_aws_configure_os="$(uname -s)"
        [[ "''${_soxin_aws_configure_os}" == "Darwin" ]]
      }

      isLinux() {
        local _soxin_aws_configure_os="$(uname -s)"
        [[ "''${_soxin_aws_configure_os}" == "Linux" ]]
      }

      if isLinux; then
        _soxin_aws_configure_secretsPath="/run/secrets"
      elif isDarwin; then
        noteEcho "Waiting for secrets..."
        sleep 3
        _soxin_aws_configure_secretsPath="$(/usr/bin/getconf DARWIN_USER_TEMP_DIR)/secrets"
        for i in $(seq 1 10)
        do
          if [[ ! -d "$_soxin_aws_configure_secretsPath" ]]; then
            noteEcho "Waiting for secrets..."
            sleep 1
          else
            break
          fi
        done
      else
        warnEcho "AWS Configuration: OS '$os' is not supported"
        exit 1
      fi

      _soxin_aws_configure_profiles_found=0
      for sh in "$_soxin_aws_configure_secretsPath"/_aws_configure_profile_*_sh; do
        _soxin_aws_configure_profiles_found=1
        # run it in a subshell but only if it's executable
        if [[ -x $sh ]]; then
          (PATH=${pkgs.awscli}/bin:$PATH exec $sh)
        else
          warnEcho "$sh is not executable, skipping it."
        fi
      done

      if [[ $_soxin_aws_configure_profiles_found -eq 0 ]]; then
        warnEcho "No AWS configurators were found"
      fi
    ''
  );
}
