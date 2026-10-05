{
  lib,
  mode,
  ...
}:

{
  imports = lib.optional (mode == "home-manager") ./home.nix;

  options.soxincfg.programs.maktab = {
    enable = lib.mkEnableOption "maktab, the story workspace manager (with `mk`), and the `majlis` CLI its workers report with";

    hooks = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.lines);
      default = { };
      example = lib.literalExpression ''
        {
          post-worktree-create."10-direnv" = '''
            #!/bin/sh
            direnv allow "$MAKTAB_WORKTREE_PATH"
          ''';
        }
      '';
      description = ''
        Global hooks, as event -> file name -> script. Each is written,
        executable, to maktab's `hooks/<event>.d/<name>` under its config
        directory, and runs for every repository. Per-repository hooks live in
        that repository's `.maktab/hooks/` and are not managed here.
      '';
    };
  };
}
