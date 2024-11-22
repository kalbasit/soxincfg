{ config, pkgs, ... }:

{
  home.file = {
    ".npmrc".text = "prefix=${config.home.homeDirectory}/.filesystem";

    # xinit will start an ssh-agent overshadowing the agent I created for qubes
    ".profile".text = "export SSH_AUTH_SOCK=/run/user/$(id -u)/qubes-ssh-agent.socket";
  };

  systemd.user.services.qubes-ssh-agent = {
    Unit = {
      Description = "Split SSH Agent Socket for Vault SSH";
    };

    Service = {
      ExecStart = ''
        ${pkgs.socat}/bin/socat -d -d "UNIX-LISTEN:%t/qubes-ssh-agent.socket,mode=600,fork,unlink-early" "EXEC:qrexec-client-vm vault qubes.SshAgent"
      '';
      Restart = "always";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
