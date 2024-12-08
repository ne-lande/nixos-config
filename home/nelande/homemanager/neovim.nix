{ pkgs, ... }: {
  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      vim-airline
      vim-airline-themes
      vim-surround
      nerdtree
      vim-polyglot
      YouCompleteMe
      vim-suda
      vim-commentary
    ];

    extraConfig = ''
      syntax on

      set clipboard=unnamedplus
      set number
      set signcolumn=yes
      set encoding=UTF-8
      set mouse=a
      set nocompatible
      set tabstop=4
      set shiftwidth=4
      set expandtab
      set nomagic

      set t_Co=256
      if has('termguicolors')
          set termguicolors
      endif

      highlight clear SignColumn
      highlight LineNr ctermfg=grey

      highlight Normal guibg=none
      highlight NonText guibg=none
      highlight Normal ctermbg=none
      highlight NonText ctermbg=none

      let g:airline_theme='dark'
      let g:airline_section_b = '%{strftime("%c")}'
      let g:airline_powerline_fonts = 1

      let g:ycm_extra_conf_globlist = 1
      let g:ycm_confirm_extra_conf = 1
      let g:ycm_auto_trigger = 1

      autocmd VimEnter * NERDTree
      nnoremap <C-t> :NERDTreeToggle <CR>
      '';
     };
}
