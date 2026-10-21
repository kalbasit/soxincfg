# soxincfg's flake on Soxin v2 (Soxin's layer on Clan).
#
# soxincfg defines no machines of its own: a fleet's flake calls
# `soxincfg.lib.mkFlake { hosts, home-managers, supportedSystems, vars }`,
# which takes hosts in v1's shape (mode, system, channelName, modules,
# specialArgs). A host's v1 `deploy` (deploy-rs) is ignored: Soxin v2
# machines deploy with Clan.
#
# What the calling flake adds, all optional:
#
# - `inputs`: its own flake inputs, `self` among them. They are laid over
#   soxincfg's: `self` is then the calling flake (the `soxincfg` special
#   argument, the configuration revision, the Nix registry), and its other
#   inputs reach the modules through the `inputs` special argument.
# - `overlays`: overlays applied to the `nixpkgs` channel after soxincfg's.
# - `modules`: modules in modules/list.nix's shape (a path, or an attribute
#   set of its nixos, darwin and home modules, by name). They join
#   soxincfg's modules, in list.nix's order, on every configuration.
# - `profiles`: a function of the kind ("nixos", "darwin", "home") to more
#   profiles, laid over the profile tree (`<kind>Modules.profiles`).
#
# Soxin v1's modules are copied into soxinv1/ (the `soxinLib` argument is
# their library), and every module is split per kind, without `mode`;
# `hostType` still names the host's operating system.
soxincfgInputs@{
  flake-utils-plus,
  nixos-hardware,
  nixos-wsl,
  nixpkgs,
  nixpkgs-unstable,
  nur,
  pre-commit-hooks,
  sops-nix,
  soxin,
  ...
}:

{
  home-managers,
  hosts,
  supportedSystems,
  vars ? { },
  inputs ? { },
  overlays ? [ ],
  modules ? { },
  profiles ? _: { },
}:
let
  # The calling flake's inputs over soxincfg's own.
  allInputs = soxincfgInputs // inputs;

  inherit (allInputs) self;

  inherit (nixpkgs.lib)
    filterAttrs
    mapAttrs
    mapAttrsToList
    optionalAttrs
    removeAttrs
    unique
    ;

  # Channel definitions, as in v1: the release with packages from unstable,
  # and unstable.
  channels = {
    nixpkgs = {
      config = {
        permittedInsecurePackages = [
          # TODO: This is needed to make onlykey-agent installable. It's currently failing due to a know CVE.
          # https://github.com/trustcrypto/python-onlykey/issues/82#issuecomment-3503421686
          "python3.13-ecdsa-0.19.2"
        ];
      };

      input = nixpkgs;

      overlays =
        channels:
        [
          (_: super: {
            inherit (channels.nixpkgs-unstable)
              # inherit packages from unstable.
              aerospace
              antigravity
              bitwarden-cli
              cilium-cli
              claude-mergetool
              claude-monitor
              codex
              flyctl
              git-spice
              hubble
              openspec
              protonvpn-gui
              secretive
              ssh-agent-mux
              talosctl
              turso-cli
              worktrunk
              ;

            # Pinned ahead of nixpkgs-unstable: the API refuses Claude Code
            # releases it no longer supports, and bumping the whole channel for
            # it is not always wanted. The manifest is Anthropic's release
            # manifest for the version; drop the override once unstable catches up.
            claude-code = channels.nixpkgs-unstable.claude-code.override {
              manifest = super.lib.importJSON ./claude-code-manifest.json;
            };

            # direnv tests are failing on aarch64-darwin
            # https://github.com/NixOS/nixpkgs/issues/507531
            direnv = super.direnv.overrideAttrs (_: {
              doCheck = !super.stdenv.hostPlatform.isDarwin;
            });

            # glances is not cached for aarch64-linux and its tests fail when
            # built on the aarch64 VM: psutil reports no physical cores inside
            # the build sandbox, and the XML-RPC tests time out under load.
            glances =
              if super.stdenv.hostPlatform.isAarch64 && super.stdenv.hostPlatform.isLinux then
                super.glances.overridePythonAttrs (oa: {
                  disabledTests = (oa.disabledTests or [ ]) ++ [ "test_phys_core_returns_int" ];
                  disabledTestPaths = (oa.disabledTestPaths or [ ]) ++ [ "tests/test_xmlrpc.py" ];
                })
              else
                super.glances;
          })
        ]
        # The calling flake's overlays.
        ++ overlays
        # v1 (flake-utils-plus) put its own overlay last on every channel.
        ++ [ flake-utils-plus.overlay ];
    };

    nixpkgs-unstable = {
      config = { };

      input = nixpkgs-unstable;

      overlays = _: [ flake-utils-plus.overlay ];
    };
  };

  # Default configuration values for `channels.<name>.config = {...}`
  channelsConfig = {
    # allowBroken = true;
    allowUnfree = true;
    # allowUnsupportedSystem = true;

    permittedInsecurePackages = [ ];
  };

  # The overlays v1 applied to every channel, in v1's order: flake-utils-plus's
  # `srcs`, Soxin v1's package set (copied into soxinv1/), NUR, soxincfg's own
  # and sops-nix's.
  sharedOverlays = [
    (_: _: {
      __dontExport = true;
      srcs = filterAttrs (_: value: !value ? outputs) allInputs;
    })
    (_: prev: { soxin = import ../soxinv1/pkgs prev; })
    nur.overlays.default
    (import ../overlays)
    sops-nix.overlays.default
  ];

  # The module of one kind ("nixos", "darwin", "home") of a list.nix entry.
  pick = kind: module: if builtins.isAttrs module then module.${kind} else module;

  # soxincfg's modules and the calling flake's, by name. A module is imported
  # in the order of its name, as modules/kind.nix does.
  moduleList = import ../modules/list.nix // modules;

  # All of moduleList for one kind, as modules/kind.nix is all of modules/.
  soxincfgModuleOf = kind: {
    imports = map (pick kind) (builtins.attrValues moduleList);
  };

  # The profile tree of one kind, with the calling flake's profiles.
  profilesOf = kind: import ../profiles/kind.nix kind // profiles kind;

  # soxincfg's module library for one kind ("nixos", "darwin", "home"):
  # `soxincfg` (all of modules/), `soxin` (all of mysoxin/), `profiles` (the
  # profile tree) and every module of modules/ and mysoxin/ by its name.
  modulesOf =
    kind:
    nixpkgs.lib.mapAttrs (_: pick kind) (import ../mysoxin/list.nix)
    // nixpkgs.lib.mapAttrs (_: pick kind) moduleList
    // {
      profiles = profilesOf kind;
      soxin = import ../mysoxin/kind.nix kind;
      soxincfg = soxincfgModuleOf kind;
    };

  nixosModules = modulesOf "nixos";

  nixosModule = nixosModules.soxincfg;

  # Modules every configuration of a kind ("nixos", "darwin", "home") gets.
  globalModules = kind: [
    (soxincfgModuleOf kind)
    (profilesOf kind).core

    # import mysoxin
    # TODO: Get rid of this!
    (import ../mysoxin/kind.nix kind)
  ];

  # Soxin v1's modules, copied into soxinv1/ (without its keyboard and theme
  # settings, which come from Soxin's library under the same option names),
  # where v1's nixosModule was.
  v1Modules = kind: [
    (import ../soxinv1/modules/kind.nix kind)
    soxin.lib.library.${kind}.settings-keyboard
    soxin.lib.library.${kind}.settings-theme
  ];

  # What v1 (Soxin and flake-utils-plus) set on every NixOS and nix-darwin
  # host, kept so the move to v2 does not change the systems.
  v1SystemModule =
    {
      lib,
      options,
      pkgs,
      ...
    }:
    {
      _type = "merge";
      contents = [
        (optionalAttrs (options ? networking.domain) {
          networking.domain = lib.mkDefault null;
        })

        (optionalAttrs (options ? nixpkgs.pkgs) {
          nixpkgs.config = lib.mkForce { };
        })

        (optionalAttrs (options ? system.configurationRevision) {
          system.configurationRevision = lib.mkIf (self ? rev) self.rev;
        })

        (optionalAttrs (options ? nix.package) {
          nix.package = lib.mkDefault pkgs.nixVersions.latest;
        })

        (optionalAttrs (options ? nix.extraOptions) {
          nix.extraOptions = "extra-experimental-features = nix-command flakes";
        })

        # v1 built hosts with the `lib` of the channel's package set, which,
        # unlike the nixpkgs flake's, carries no revision; the versions below
        # default to what that `lib` says.
        (optionalAttrs (options ? system.nixos.revision) {
          system.nixos.revision = lib.mkDefault (pkgs.lib.trivial.revisionWithDefault null);
          system.nixos.versionSuffix = lib.mkDefault pkgs.lib.trivial.versionSuffix;
        })

        (optionalAttrs (options ? system.nixpkgsRevision) {
          system.nixpkgsRevision = lib.mkDefault (pkgs.lib.trivial.revisionWithDefault null);
          system.nixpkgsVersionSuffix = lib.mkDefault pkgs.lib.trivial.versionSuffix;
        })
      ];
    };

  # Clan's core module sets a ZFS host id (/etc/hostid, also in
  # the initrd) and ZFS defaults on every NixOS machine, outside its
  # recommended defaults. They are left out so the machines stay as v1 built
  # them.
  noClanZfsModule = {
    disabledModules = [ "${soxin.inputs.clan-core}/nixosModules/clanCore/zfs.nix" ];
  };

  # The kind of a v1 host.
  kindOf =
    name: host:
    if (host.mode or "NixOS") == "NixOS" then
      "nixos"
    else if host.mode == "nix-darwin" then
      "darwin"
    else
      throw "soxincfg: host `${name}` has mode `${host.mode}`, which is neither NixOS nor nix-darwin";

  # A v1 host as a Soxin host.
  hostOf = kind: name: host: {
    inherit kind;
    inherit (host) system;
    channel = host.channelName or "nixpkgs";
    modules =
      (host.modules or [ ])
      # v1 added sops-nix to NixOS hosts only, after the host's modules.
      ++ nixpkgs.lib.optional (kind == "nixos") sops-nix.nixosModules.sops;
    specialArgs = host.specialArgs or { };
  };

  # `hostType` switches `imports` in soxincfg's modules, so it has to be a
  # special argument. Clan passes the same special arguments to every machine,
  # so it is given per kind; every host of a kind must agree on it.
  hostTypeOf =
    hosts: kind:
    let
      types = unique (
        mapAttrsToList (_: host: host.specialArgs.hostType or null) (
          filterAttrs (name: host: kindOf name host == kind) hosts
        )
      );
    in
    if types == [ ] then
      { }
    else if builtins.length types == 1 && builtins.head types != null then
      { hostType = builtins.head types; }
    else
      throw "soxincfg: the ${kind} hosts do not agree on hostType";

  outputs = soxin.lib.mkFleet {
    inputs = allInputs;
    systems = supportedSystems;

    inherit channels channelsConfig sharedOverlays;

    hosts =
      mapAttrs (name: host: hostOf (kindOf name host) name host) hosts
      // mapAttrs (name: host: {
        kind = "home-manager";
        inherit (host) system;
        channel = host.channelName or "nixpkgs";
        modules = host.modules or [ ];
        specialArgs = host.specialArgs or { };
      }) home-managers;

    modules = {
      nixos = [
        v1SystemModule
        noClanZfsModule
      ]
      ++ globalModules "nixos"
      ++ v1Modules "nixos";
      darwin = [ v1SystemModule ] ++ globalModules "darwin" ++ v1Modules "darwin";
      home =
        globalModules "home"
        ++ [ "${sops-nix.sourceInfo.outPath}/modules/home-manager/sops.nix" ]
        ++ v1Modules "home";
    };

    # v1's arguments, and `soxinLib`, the library of Soxin v1's modules
    # (copied into soxinv1/).
    specialArgs = {
      global = {
        inherit (allInputs) home-manager;
        soxincfg = self;
        soxinLib = import ../soxinv1/lib allInputs;
      };
      nixos = {
        inherit nixos-hardware nixos-wsl;
      }
      // hostTypeOf hosts "nixos";
      darwin = hostTypeOf hosts "darwin";
    };

    # sops-nix is added by hand, where v1 added it.
    sops.enable = false;

    # v1 (flake-utils-plus) pinned the Nix registry, NIX_PATH and
    # /etc/nix/inputs to the flake's inputs.
    pinInputs = {
      registry = true;
      nixPath = true;
    };

    imports = [
      (
        { lib, ... }:
        {
          # soxincfg names its nix-darwin input `darwin`.
          fleet.inputs.nix-darwin = allInputs.darwin;

          # soxincfg places the modules of Soxin's library itself, where the
          # modules they replace were.
          fleet.library.enable = false;

          # Clan's recommended defaults are off, so Clan adds
          # nothing to the machines that v1 did not have.
          flake.clan.machines = lib.mapAttrs (_: _: {
            clan.core.enableRecommendedDefaults = false;
          }) hosts;

          flake.clan.meta.name = "soxincfg";

          perSystem =
            { pkgs, system, ... }:
            let
              pre-commit-check = pre-commit-hooks.lib.${system}.run {
                src = ../.;
                hooks = {
                  statix.enable = true;
                  nixfmt-rfc-style.enable = true;
                };
              };
            in
            {
              checks = { inherit pre-commit-check; };

              devShells.default = pkgs.mkShell {
                inherit (pre-commit-check) shellHook;
                buildInputs = [
                  pkgs.nixfmt-rfc-style
                  pkgs.nix-output-monitor
                  # Clan's CLI, from the clan-core Soxin builds the fleet with.
                  soxin.inputs.clan-core.packages.${system}.clan-cli
                ];
              };

              formatter = pkgs.nixfmt-rfc-style;

              # these packages construct themselves if and only if the system is supported.
              packages = import ../pkgs pkgs;
            };
        }
      )
    ];
  };
in
# flake-parts types `nixosModules` (and Clan `darwinModules`) as modules, but
# soxincfg's modules read `soxincfg.<kind>Modules.profiles.<name>` as a tree of
# modules, so the library is put back as it is.
outputs
// {
  nixosModules = outputs.nixosModules // nixosModules;
  darwinModules = outputs.darwinModules // modulesOf "darwin";
  homeModules = modulesOf "home";
  inherit nixosModule;
  inherit vars;
}
