# soxincfg's flake on Soxin v2 (Soxin's layer on Clan).
#
# The interface is unchanged: `mkFlake { hosts, home-managers,
# supportedSystems, vars }` takes hosts in v1's shape (mode, system,
# channelName, modules, specialArgs, deploy), so the private flake keeps
# calling it as it did. The modules are not touched: they still use Soxin
# v1's modules (`soxin-v1`), its `soxin` argument and the `mode`/`hostType`
# switches, so a nix-diff against the v1 build measures the framework alone.
inputs@{
  flake-utils-plus,
  nixos-hardware,
  nixos-wsl,
  nixpkgs,
  nixpkgs-unstable,
  nur,
  pre-commit-hooks,
  self,
  sops-nix,
  soxin,
  soxin-v1,
  ...
}:
let
  inherit (nixpkgs.lib)
    filterAttrs
    mapAttrs
    mapAttrsToList
    optionalAttrs
    recursiveUpdate
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

            # From diwan: the host agent only of Nazir (its flake also builds the
            # control plane and its image, and neither belongs on a machine that
            # merely runs work); maktab with its plugins; and majlis, the CLI
            # workers report with. majlis-mcp is taken by whichever configuration
            # runs the assistant.
            inherit (inputs.diwan.packages.${super.stdenv.hostPlatform.system})
              majlis
              maktab-full
              nazir-agent
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
          })
        ]
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
  # `srcs`, Soxin v1's package set, NUR, soxincfg's own and sops-nix's.
  sharedOverlays = [
    (_: _: {
      __dontExport = true;
      srcs = filterAttrs (_: value: !value ? outputs) inputs;
    })
    soxin-v1.overlays.default
    nur.overlays.default
    (import ../overlays)
    sops-nix.overlays.default
  ];

  nixosModules = {
    profiles = import ../profiles;
    soxin = import ../mysoxin/soxin.nix; # TODO: Get rid of this!
    soxincfg = import ../modules;
  };

  nixosModule = nixosModules.soxincfg;

  # Modules every NixOS, nix-darwin and home-manager configuration gets.
  globalModules = [
    nixosModule
    nixosModules.profiles.core

    # import mysoxin
    # TODO: Get rid of this!
    nixosModules.soxin
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

  # v1's Nix registry, NIX_PATH and /etc/nix/inputs from the flake's inputs.
  v1RegistryModules = [
    "${flake-utils-plus}/lib/options.nix"
    {
      nix = {
        generateNixPathFromInputs = true;
        generateRegistryFromInputs = true;
        linkInputs = true;
      };
    }
  ];

  # Provisional: Clan's core module sets a ZFS host id (/etc/hostid, also in
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

  # A v1 deploy-rs node as a Soxin host's `deploy`.
  deployOf =
    host:
    let
      node = host.deploy or { };
      profile = node.profiles.system or { };
    in
    optionalAttrs (node ? hostname) {
      inherit (node) hostname;
      sshUser = profile.sshUser or null;
      user = profile.user or "root";
      settings = removeAttrs profile [
        "sshUser"
        "user"
        "path"
      ];
    };

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
    deploy = deployOf host;
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
in

{
  home-managers,
  hosts,
  supportedSystems,
  vars ? { },
}:
let
  outputs = soxin.lib.mkFleet {
    inherit inputs;
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
      ++ globalModules
      ++ [ soxin-v1.nixosModule ]
      ++ v1RegistryModules;
      darwin = [ v1SystemModule ] ++ globalModules ++ [ soxin-v1.nixosModule ] ++ v1RegistryModules;
      home = globalModules ++ [
        "${sops-nix.sourceInfo.outPath}/modules/home-manager/sops.nix"
        soxin-v1.nixosModule
      ];
    };

    # v1's arguments: soxincfg's modules take `soxin` to be Soxin v1, whose
    # module library they still use.
    specialArgs = {
      global = {
        inherit (inputs) home-manager;
        soxin = soxin-v1;
        soxincfg = self;
      };
      nixos = {
        inherit nixos-hardware nixos-wsl;
      }
      // hostTypeOf hosts "nixos";
      darwin = hostTypeOf hosts "darwin";
    };

    # sops-nix is added by hand, where v1 added it.
    sops.enable = false;

    imports = [
      (
        { lib, ... }:
        {
          # soxincfg names its nix-darwin input `darwin`.
          fleet.inputs.nix-darwin = inputs.darwin;

          # Provisional: Clan's recommended defaults are off, so Clan adds
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
# flake-parts types `nixosModules` as modules, but soxincfg's modules read
# `soxincfg.nixosModules.profiles.<name>` as a tree of modules, so the tree is
# put back as it is.
outputs
// {
  nixosModules = outputs.nixosModules // nixosModules;
  inherit nixosModule;
  vars = recursiveUpdate (import ../vars inputs) vars;
}
