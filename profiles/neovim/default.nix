{
  soxincfg.programs.neovim = {
    enable = true;
    completion.enable = true;
    lsp = {
      enable = true;
      lightbulb = true;
      languages = {
        bash = true;
        clang = true;
        css = true;
        docker = true;
        go = true;
        html = true;
        json = true;
        nix = true;
        python = true;
        tex = true;
        typescript = true;
        vimscript = true;
        yaml = true;
      };
    };
    telescope.enable = true;
    treesitter.enable = true;
  };
}
