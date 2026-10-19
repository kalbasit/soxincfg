# soxincfg
Soxin configuration

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
