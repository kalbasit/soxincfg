{
  config,
  nixos-wsl,
  pkgs,
  ...
}:

{
  imports = [ nixos-wsl.nixosModules.default ];

  wsl = {
    enable = true;
    defaultUser = config.soxincfg.settings.users.userName;

    # Expose the Windows GPU driver (/dev/dxg and /usr/lib/wsl/lib). This is a
    # gaming machine, so GPU compute inside the guest is worth having.
    useWindowsDriver = true;

    # Register the binfmt_misc handler for Windows executables. Without this
    # `powershell.exe` and friends fail with "Exec format error" -- WSL does not
    # reliably install the handler on systemd distros. Interop is how the
    # Windows-side gaming work (Playnite) stays reachable from here.
    interop.register = true;
  };

  # Required by ~/.claude/hooks/block-sops-dirs.py, which the claude-code module
  # wires into settings.json as `python3 $HOME/.claude/hooks/...`.
  environment.systemPackages = [ pkgs.python3 ];
}
