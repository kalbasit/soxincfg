{
  # Enable the installation of my neovim
  # TODO: Need a minimal neovim with just my keybindings
  # soxin.programs.neovim.enable = true;

  # Enable SSH server on all of my hosts
  soxin.services.openssh.enable = true;

  # Setup my keyboard layout
  soxin.settings.keyboard = {
    layouts = [
      { console = { keyMap = "colemak"; }; }
    ];
  };
}
