# The profiles for one kind of configuration ("nixos", "darwin" or "home"), as
# the tree soxincfg's configuration takes them from: soxincfg.nixosModules.profiles,
# soxincfg.darwinModules.profiles and soxincfg.homeModules.profiles.
kind: {
  core = import (./core + "/${kind}.nix");
  miniserver = {
    metal = import (./miniserver/metal + "/${kind}.nix");
    qemu-vm-guest = import (./miniserver/qemu-vm-guest + "/${kind}.nix");
  };
  myself = import (./myself + "/${kind}.nix");
  neovim = {
    full = import ./neovim/full;
    mini = import ./neovim/mini;
  };
  server = import (./server + "/${kind}.nix");
}
