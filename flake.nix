{
  description = "A flake for fully-featured Neovim";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }: 
    flake-utils.lib.eachDefaultSystem (system: 
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {};
        };
        nvim = pkgs.neovim.override {
          configure = {

            customRC = ''
set noswapfile
autocmd VimEnter * colorscheme gruvbox
let mapleader = "<SPACE>"

nnoremap <SPACE><SPACE><SPACE> :noh <CR>
nnoremap <SPACE>t <cmd>CHADopen<cr>
nnoremap <SPACE>l <cmd>Telescope live_grep<cr>
nnoremap <SPACE>f <cmd>Telescope find_files<cr>
nnoremap <SPACE>b <cmd>Telescope buffers<cr>

" --- Copy to clipboard --- "
vnoremap y  "+y
nnoremap Y  "+yg_
nnoremap y  "+y
nnoremap yy "+yy

" --- Paste from clipboard --- "
nnoremap <leader>p  "+p
nnoremap <leader>P  "+P

" --- init.lua --- "
lua <<EOF

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local bufmap = function(mode, lhs, rhs)
      local opts = {buffer = event.buf}
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- You can find details of these function in the help page
    -- see for example, :help vim.lsp.buf.hover()

    -- Trigger code completion
    bufmap('i', '<C-Space>', '<C-x><C-o>')

    -- Display documentation of the symbol under the cursor
    bufmap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')

    -- Jump to the definition
    bufmap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')

    -- Jump to declaration
    bufmap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')

    -- Lists all the implementations for the symbol under the cursor
    bufmap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')

    -- Jumps to the definition of the type symbol
    bufmap('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>')

    -- Lists all the references 
    bufmap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>')

    -- Displays a function's signature information
    bufmap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<cr>')

    -- Renames all references to the symbol under the cursor
    bufmap('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>')

    -- Format current file
    bufmap('n', '<Space><Space>', '<cmd>lua vim.lsp.buf.format()<cr>')

    -- Selects a code action available at the current cursor position
    bufmap('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>')
  end
})

local MY_FQBN = "esp32:esp32:esp32"
require'lspconfig'.arduino_language_server.setup{
  cmd = {
        "arduino-language-server",
        "-cli-config", "/home/fabrizio/.arduino15/arduino-cli.yaml",
        "-fqbn",
        MY_FQBN
    }
}
EOF
            '';

            packages.myVimPackage = with pkgs.vimPlugins; {
              start = [ 
	                vim-fugitive
			gruvbox
			chadtree
			telescope-nvim
			telescope-file-browser-nvim
			nvim-lspconfig
			nvim-web-devicons
			nvim-treesitter
			nvim-treesitter-parsers.arduino
		];
              opt = [ ];
            };
          };
        };
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = [ 
		    nvim
	            pkgs.python311
	            pkgs.python311Packages.pyserial
		    pkgs.ripgrep
		    pkgs.clang-tools
		    pkgs.arduino-language-server
		    pkgs.arduino-cli
	    ];
	  shellHook = ''
            alias vi="nvim"
          '';
        };

        apps.nvim = {
          type = "app";
          program = "${nvim}/bin/nvim";
        };
      }
    );
}

