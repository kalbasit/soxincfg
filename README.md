# soxincfg
Soxin configuration

## Hosts live in a private flake

soxincfg holds no machines. Its hosts, their secrets and the modules that are
private to them live in a private flake, which builds them by calling
`soxincfg.lib.mkFlake`:

```nix
{
  inputs.soxincfg.url = "github:kalbasit/soxincfg";

  outputs =
    inputs@{ soxincfg, ... }:
    soxincfg.lib.mkFlake {
      inherit inputs; # the calling flake's inputs, `self` among them
      hosts = import ./hosts (soxincfg.inputs // inputs);
      home-managers = { };
      supportedSystems = [ "aarch64-darwin" "x86_64-linux" ];
      vars = import ./vars;           # optional: soxincfg.vars
      overlays = [ ];                 # optional: on the nixpkgs channel
      modules = import ./modules/list.nix; # optional: list.nix's shape
      profiles = import ./profiles/kind.nix; # optional: kind -> profiles
    };
}
```

`hosts` and `home-managers` take hosts in Soxin v1's shape (`mode`, `system`,
`channelName`, `modules`, `specialArgs`). The extra modules join soxincfg's in
the order of their names, and the extra profiles are laid over
`<kind>Modules.profiles`. See `lib/mk-flake.nix`.

soxincfg's own flake builds an empty fleet, for its checks, development shell
(with Clan's CLI), formatter and packages.

Some modules keep a generic option whose value is the fleet's, for example
the sops file of `soxincfg.hardware.onlykey`, `soxincfg.programs.dbeaver` and
`soxincfg.services.sleep-on-lan` (`sopsFile`), the story manager of
`soxincfg.services.aerospace` (`storyManager`, `storyEnv`) and the zsh init
script (`soxincfg.programs.zsh.initExtraFile`).

## Module outputs

soxincfg is built with Soxin v2 and exports its module library per kind, for
other fleets to import. The names are stable:

| Output | What |
| --- | --- |
| `nixosModules.soxincfg`, `darwinModules.soxincfg`, `homeModules.soxincfg` | every module of `modules/` for that kind |
| `nixosModules.soxin`, `darwinModules.soxin`, `homeModules.soxin` | every module of `mysoxin/` for that kind (options under `soxin.*`) |
| `nixosModules.profiles`, `darwinModules.profiles`, `homeModules.profiles` | the profile tree for that kind, e.g. `homeModules.profiles.neovim.full` |
| `<kind>Modules.<name>` | one module of `modules/` or `mysoxin/` by its name in `list.nix`, e.g. `homeModules.git`, `nixosModules.docker` |

`nixosModule` is `nixosModules.soxincfg`. Where `modules/` and `mysoxin/`
share a name (`i3`), `<kind>Modules.<name>` is the one from `modules/`.

A module is one file per kind (`nixos.nix`, `darwin.nix`, `home.nix`, each
importing what the kind needs); there is no `mode` argument. Modules take
`inputs`, `soxin`, `soxincfg`, `soxinLib` (Soxin v1's option types, see
`soxinv1/`) and `hostType` (the host's operating system), as soxincfg's
`lib.mkFlake` passes them; a fleet importing them passes the same.

`soxinv1/` holds what soxincfg still uses of Soxin v1 (MIT, see
`soxinv1/LICENSE`).
