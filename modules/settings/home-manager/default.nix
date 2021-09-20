{ lib, mode, ... }:

let
  inherit (lib)
    optionalAttrs
    ;
in
optionalAttrs (mode == "home-manager") {
  home.activation.aws-credentials = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    _soxin_aws_configure_profiles_found=0
    for sh in /run/secrets/_aws_configure_profile_*_sh; do
      _soxin_aws_configure_profiles_found=1
      # run it in a subshell but only if it's executable
      if [[ -x $sh ]]; then
        (exec $sh)
      else
        warnEcho "$sh is not executable, skipping it."
      fi
    done

    if [[ $_soxin_aws_configure_profiles_found -eq 0 ]]; then
      warnEcho "No AWS configurators were found"
    fi
  '';
}
