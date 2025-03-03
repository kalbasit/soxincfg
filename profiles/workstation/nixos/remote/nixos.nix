{ config, pkgs, ... }:

{
  environment.homeBinInPath = true;

  services = {
    eternal-terminal.enable = true;

    # Enable TailScale for zero-config VPN service.
    tailscale.enable = true;

    # Allow the forwarding of the GnuPG extra socket.
    # https://wiki.gnupg.org/AgentForwarding
    openssh.extraConfig = ''
      StreamLocalBindUnlink yes
    '';
  };

  # While creating the user runtime directories, create the gnupg directories
  # as well if the user is YL.
  # This is meant to solve this ssh issue:
  #
  #  > ssh zeus
  #  Error: remote port forwarding failed for listen path /run/user/2000/gnupg/S.gpg-agent
  systemd.services."user-runtime-dir@".serviceConfig.ExecStartPost =
    with pkgs;
    let
      script = writeScript "create-run-user-gnupg.sh" ''
        #!${runtimeShell}
        set -euo pipefail

        if [[ "$1" != "${builtins.toString config.users.users.yl.uid}" ]]; then exit 0; fi

        mkdir -m 700 /run/user/$1/gnupg
        chown $1 /run/user/$1/gnupg
      '';
    in
    "${script} %i";
}
