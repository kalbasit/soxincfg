# The profiles for one kind of configuration ("nixos", "darwin" or "home"), as
# the tree soxincfg's configuration takes them from: soxincfg.nixosModules.profiles,
# soxincfg.darwinModules.profiles and soxincfg.homeModules.profiles.
kind: {
  core = import (./core + "/${kind}.nix");
  code = import (./code + "/${kind}.nix");
  miniserver = {
    metal = import (./miniserver/metal + "/${kind}.nix");
    qemu-vm-guest = import (./miniserver/qemu-vm-guest + "/${kind}.nix");
  };
  myself = import (./myself + "/${kind}.nix");
  neovim = {
    full = import ./neovim/full;
    mini = import ./neovim/mini;
  };
  personal = import (./personal + "/${kind}.nix");
  server = import (./server + "/${kind}.nix");
  tailscale = {
    basicdns = import (./tailscale/basicdns + "/${kind}.nix");
    dns = import (./tailscale/dns + "/${kind}.nix");
    exit-node = import (./tailscale/exit-node + "/${kind}.nix");
    subnet-router = import (./tailscale/subnet-router + "/${kind}.nix");
  };
  workstation = {
    chromeos = {
      local = import (./workstation/chromeos/local + "/${kind}.nix");
    };
    common = import (./workstation/common + "/${kind}.nix");
    darwin = {
      local = import (./workstation/darwin/local + "/${kind}.nix");
    };
    linux = {
      local = import (./workstation/linux/local + "/${kind}.nix");
      remote = import (./workstation/linux/remote + "/${kind}.nix");
    };
    nixos = {
      local = import (./workstation/nixos/local + "/${kind}.nix");
      remote = import (./workstation/nixos/remote + "/${kind}.nix");
      vm-guest = import (./workstation/nixos/vm-guest + "/${kind}.nix");
    };
    qubes = {
      local = import (./workstation/qubes/local + "/${kind}.nix");
    };
  };
  wsl-gaming = import (./wsl-gaming + "/${kind}.nix");
}
