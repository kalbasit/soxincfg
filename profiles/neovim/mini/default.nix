{ pkgs, ... }:
{
  soxincfg.programs.neovim = {
    enable = true;

    package = pkgs.wrapNeovim pkgs.neovim-unwrapped {
      configure = {
        packages.myVimPackage = with pkgs.vimPlugins; {
          start = [ vim-colemak ];
        };
      };

      viAlias = true;
      vimAlias = true;
    };
  };
}
