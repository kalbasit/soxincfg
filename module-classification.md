# Module classification for the move to Soxin v2

Every module soxincfg uses, for the module cleanup (design steps 5.1 to 5.4).
**This is a proposal; nothing moves until the operator approves it.**

- **PUBLIC**: generic; moves to Soxin as it is (minus `mode`).
- **PRIVATE**: stays in soxincfg: useful to the operator alone, too opinionated,
  or touching the diwan input, the agent tooling, private hosts, users, keys,
  paths or secrets (the Soxin hard rule wins over genericity).
- **SPLIT**: a generic core goes public; the operator's values (identity,
  layouts, keybindings, hosts, secrets) stay here as configuration on top.

`mode` is the number of `mode` references in the module (`hostType` noted where
it is also used); "pilot" marks the modules already split per kind without
`mode` (commit "pilot batch without `mode`").

## soxincfg `modules/` (namespace `soxincfg.*`)

| Path | mode | Class | Reason |
| --- | --- | --- | --- |
| modules/hardware/onlykey | 5 | SPLIT | OnlyKey + gpg-agent wiring is generic; the sops-held ssh key handle and agent mux choice are the operator's |
| modules/hardware/yubikey | 4 | PUBLIC | YubiKey/gpg-agent/ssh support with options only, no personal values |
| modules/programs/android (pilot) | 0 (was 2) | PUBLIC | adb plus the `adbusers` group |
| modules/programs/autorandr.nix | 2 | PUBLIC | thin enable over v1's autorandr |
| modules/programs/brave.nix | 2 | PUBLIC | browser enable and policies, no personal data |
| modules/programs/chromium | 3 | SPLIT | chromium module generic; the extension list is the operator's taste |
| modules/programs/claude-code | 6 | PRIVATE | agent tooling: diwan, maktab, MCP servers, skills, sops secrets |
| modules/programs/codex | 2 (+hostType) | PRIVATE | agent tooling and the agent skills |
| modules/programs/dbeaver | 3 | SPLIT | install is generic; the sops-encrypted credentials config is private |
| modules/programs/fzf (pilot) | 0 (was 2) | PUBLIC | small, generic |
| modules/programs/git | 2 | SPLIT | git defaults/aliases generic; name, email, signing key and sops diff driver config are the operator's |
| modules/programs/iterm2 | 3 | SPLIT | iTerm2 plumbing generic; the 3k-line profile plist with home paths is personal |
| modules/programs/maktab | 2 | PRIVATE | agent/workspace tooling (maktab, majlis) |
| modules/programs/mosh (pilot) | 0 (was 3) | PUBLIC | mosh plus firewall ports |
| modules/programs/nazir | 4 (+hostType) | PRIVATE | Nazir host agent from diwan |
| modules/programs/neovim | 6 (+hostType 5) | SPLIT | wrapper is generic; defaults to the operator's own nixvim build |
| modules/programs/pet | 2 | SPLIT | pet module generic; the snippet list is personal |
| modules/programs/rofi | 2 | SPLIT | rofi theme/config is taste on top of v1's rofi |
| modules/programs/secretive (pilot) | 0 (was 2, +hostType) | PUBLIC | Secretive cask and SSH_AUTH_SOCK on darwin |
| modules/programs/ssh | 5 | SPLIT | ssh client options generic; match blocks/hosts are private |
| modules/programs/starship (pilot) | 0 (was 2) | SPLIT | v1's starship is public already; these prompt settings are taste |
| modules/programs/termite.nix | 2 | PUBLIC | thin enable over v1's termite (consider dropping: termite is dead upstream) |
| modules/programs/tmux | 24 | SPLIT | tmux core generic; keybindings and theme are opinionated |
| modules/programs/vscode | 2 (+hostType 2) | SPLIT | editor install/settings generic; pulls in the agent skills (private) |
| modules/programs/weechat | 3 | PRIVATE | IRC config with sops-held certs and credentials |
| modules/programs/wezterm | 2 | SPLIT | wezterm enable generic; the config is taste |
| modules/programs/zed | 2 (+hostType 2) | SPLIT | editor generic; agent integration and settings personal |
| modules/programs/zellij | 2 | PUBLIC | small enable/settings |
| modules/programs/zsh | 6 | SPLIT | zsh module generic; init-extra, aliases and prompt glue are personal |
| modules/agent/skills | 0 | PRIVATE | agent tooling (skills for the assistant) |
| modules/services/aerospace | 27 | SPLIT | aerospace service generic; the 250-line keybinding config is taste |
| modules/services/dnsmasq (pilot) | 0 (was 3) | PUBLIC | dnsmasq with an optional ad blocklist |
| modules/services/x11/window-managers/i3.nix | 2 | SPLIT | layer over mysoxin's i3; i3 config is taste |
| modules/services/iscsid (pilot) | 0 (was 2) | PUBLIC | open-iscsi units, generic |
| modules/services/nextcloud | 2 | PRIVATE | the operator's own Nextcloud host, domain and secrets |
| modules/services/sleep-on-lan | 2 | SPLIT | service generic; its sops-held config is private |
| modules/services/ssh-agent-mux (pilot) | 0 (was 2) | PUBLIC | launchd agent for ssh-agent-mux, options only |
| modules/settings/fonts | 3 | SPLIT | font enable generic; the font choice is taste |
| modules/settings/gtk | 3 | SPLIT | gtk enable generic; theme choice is taste |
| modules/settings/keyboard | 3 | SPLIT | keyboard layouts generic; colemak defaults personal (overlaps v1 soxin.settings.keyboard) |
| modules/settings/networking (nextdns) | 2 | SPLIT | NextDNS option generic; the profile id is the operator's |
| modules/settings/nix | 4 | SPLIT | nix settings generic; distributed builders (hosts, keys) private |
| modules/settings/users | 3 | SPLIT | user/group plumbing generic; user name, home, password defaults private |
| modules/settings/home-manager | 2 | PUBLIC | waits for sops-nix secrets after HM activation; no private values |

## mysoxin/ (namespace `soxin.*`, v1 names kept)

| Path | mode | Class | Reason |
| --- | --- | --- | --- |
| mysoxin/hardware/fwupd.nix | 2 | PUBLIC | fwupd enable |
| mysoxin/hardware/intel-backlight.nix | 2 | PUBLIC | backlight control |
| mysoxin/hardware/lowbatt.nix | 2 | PUBLIC | low-battery notifier |
| mysoxin/hardware/serial_console.nix | 2 | PUBLIC | serial console |
| mysoxin/hardware/sound.nix | 3 | PUBLIC | sound and Focusrite quirk option |
| mysoxin/hardware/zsa | 3 | PUBLIC | ZSA keyboard udev/tools |
| mysoxin/services/caffeine.nix | 2 | PUBLIC | caffeine service |
| mysoxin/services/dunst.nix | 2 | SPLIT | dunst generic; config taste |
| mysoxin/services/x11/window-managers/i3 | 60 | SPLIT | i3 module generic; 400-line keybinding/app config personal |
| mysoxin/services/networking/networkmanager.nix | 2 | PUBLIC | NetworkManager enable |
| mysoxin/services/x11/window-managers/bar | 6 | SPLIT | polybar generic; layout taste |
| mysoxin/services/printing.nix | 2 | PUBLIC | CUPS and drivers |
| mysoxin/services/networking/ssh/sshd.nix | 2 | PUBLIC | key-only sshd |
| mysoxin/services/x11/xserver.nix | 2 | SPLIT | xserver generic; autologin user is the operator's |
| mysoxin/virtualisation/docker | 3 | PUBLIC | docker on NixOS and darwin |
| mysoxin/virtualisation/libvirtd.nix | 2 | PUBLIC | libvirtd |
| mysoxin/virtualisation/virtualbox.nix | 2 | PUBLIC | virtualbox |

## soxin-v1 module library (input `soxin-v1`, namespace `soxin.*`; already public)

| Path | mode | Class | Reason |
| --- | --- | --- | --- |
| soxin-v1:hardware/bluetooth.nix | 3 | PUBLIC | port into v2's tree without `mode` |
| soxin-v1:programs/autorandr | 3 | PUBLIC | as above |
| soxin-v1:programs/git | 3 | PUBLIC | as above; soxincfg's git layer sits on it |
| soxin-v1:programs/keybase | 3 | PUBLIC | as above |
| soxin-v1:programs/less | 2 | PUBLIC | as above |
| soxin-v1:programs/neovim | 3 | PUBLIC | as above |
| soxin-v1:programs/rbrowser | 3 | PUBLIC | as above |
| soxin-v1:programs/rofi | 2 | PUBLIC | as above |
| soxin-v1:programs/starship | 3 | PUBLIC | as above |
| soxin-v1:programs/termite | 2 | PUBLIC | as above (termite is dead upstream; candidate to drop) |
| soxin-v1:programs/tmux | 5 | PUBLIC | as above |
| soxin-v1:programs/zsh | 9 | PUBLIC | as above |
| soxin-v1:programs/vscode | 2 | PUBLIC | as above |
| soxin-v1:settings (keyboard, theme, ...) | 4 | PUBLIC | as above; reconcile with soxincfg.settings.keyboard |
| soxin-v1:themes | 1 | PUBLIC | as above |
| soxin-v1:programming-languages | 1 | PUBLIC | as above |
| soxin-v1:tools | 1 | PUBLIC | as above |

## profiles/ (bundles of settings)

Profiles are the operator's configuration, so all stay PRIVATE. Where a profile
holds generic mechanism, the mechanism moves out as a module first.

| Path | mode | Class | Reason |
| --- | --- | --- | --- |
| profiles/core | 6 | PRIVATE | the operator's base: users, caches, tailnet names, nix path |
| profiles/code | 3 | PRIVATE | dev VM profile with agent tooling and secrets |
| profiles/miniserver | 4 | PRIVATE | the operator's small-server baseline |
| profiles/myself | 7 | PRIVATE | the operator's own user |
| profiles/neovim | 0 | PRIVATE | the operator's neovim variants |
| profiles/personal | 8 (+hostType 3) | PRIVATE | personal hosts, tailnet, secrets |
| profiles/server | 3 | PRIVATE | server baseline (tailscale) |
| profiles/tailscale (basicdns, dns, exit-node, subnet-router) | 8 | PRIVATE | the operator's DNS and tailnet roles, addresses |
| profiles/workstation (common, chromeos, darwin, linux, nixos, qubes) | 25 (+hostType 6) | PRIVATE | the operator's workstation setup, agent tooling |
| profiles/wsl-gaming | 3 | PRIVATE | the operator's WSL gaming box |

## Notes

- **Overlaps.** soxincfg's git, neovim, rofi, starship, termite, tmux, zsh,
  vscode, autorandr and keyboard modules sit on v1's modules of the same name
  (they set `soxin.programs.<x>.enable`). Proposed: v1's module becomes the
  public one, extended with the generic parts of soxincfg's; soxincfg keeps the
  personal values as plain configuration.
- **Namespace.** Public modules use `soxin.*`. Moving a `soxincfg.*` module
  renames its options; soxincfg adds `mkAliasOptionModule` aliases (no warning)
  for the renamed options, so its configuration and the derivations do not
  change, and the aliases go once the configuration is rewritten.
- **Private material check.** Every PUBLIC or SPLIT core is to pass the guard
  with the outside denylist before it lands in Soxin.
