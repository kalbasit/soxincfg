{
  config,
  hostType,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkOption
    optionals
    types
    ;

  cfg = config.soxincfg.programs.neovim;
in
{
  imports =
    optionals (hostType == "linux") [ ./linux.nix ]
    ++ optionals (hostType == "NixOS") [ ./nixos.nix ]
    ++ optionals (hostType == "nix-darwin") [ ./darwin.nix ]
    ++ optionals (hostType == "qubes-os") [ ./qubes.nix ];

  options.soxincfg.programs.neovim = {
    enable = mkEnableOption "Enable NeoVim";

    config = mkOption {
      type = with types; attrsOf anything;
      default = { };
      description = "Configure NeoVim, extend my nixvim configuration";
    };

    package = mkOption {
      type = types.package;
      default = inputs.nixvim.packages."${pkgs.stdenv.hostPlatform.system}".full;
      defaultText = "A package created with nixvim's makeNixvim or makeNixvimWithModule";
      description = "The package to use for NeoVim";
      apply = pkg: pkg.extend cfg.config;
    };
  };
}
