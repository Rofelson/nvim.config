local on_attach = function(client, bufnr)
  if client.name == 'ruff_lsp' then
    -- Disable hover in favor of Pyright
    client.server_capabilities.hoverProvider = false
  end
end

return {
  {
    'quarto-dev/quarto-nvim',
    opts = {},
    dependencies = {
      'jmbuhr/otter.nvim',
      opts = {},
    },
  },
  { -- Configure `ruff-lsp`.
    -- See: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#ruff_lsp
    -- For the default config, along with instructions on how to customize the settings
    require('lspconfig').ruff_lsp.setup {
      on_attach = on_attach, -- to enable usage along Pyright
      init_options = {
        settings = {
          -- Any extra CLI arguments for `ruff` go here.
          args = {},
        },
      },
    },
  },
  {
    'jpalardy/vim-slime',
    init = function()
      vim.g.slime_target = 'neovim'
      vim.g.slime_python_ipython = 1
      vim.g.slime_dispatch_ipython_pause = 100
      vim.g.slime_cell_delimiter = '#\\s\\=%%'

      vim.cmd [[
      function! _EscapeText_quarto(text)
      if slime#config#resolve("python_ipython") && len(split(a:text,"\n")) > 1
      return ["%cpaste -q\n", slime#config#resolve("dispatch_ipython_pause"), a:text, "--\n"]
      else
      let empty_lines_pat = '\(^\|\n\)\zs\(\s*\n\+\)\+'
      let no_empty_lines = substitute(a:text, empty_lines_pat, "", "g")
      let dedent_pat = '\(^\|\n\)\zs'.matchstr(no_empty_lines, '^\s*')
      let dedented_lines = substitute(no_empty_lines, dedent_pat, "", "g")
      let except_pat = '\(elif\|else\|except\|finally\)\@!'
      let add_eol_pat = '\n\s[^\n]\+\n\zs\ze\('.except_pat.'\S\|$\)'
      return substitute(dedented_lines, add_eol_pat, "\n", "g")
      end
      endfunction
      ]]
    end,
    config = function()
      vim.keymap.set({ 'n', 'i' }, '<m-cr>', function()
        vim.cmd [[ call slime#send_cell() ]]
      end, { desc = 'send code cell to terminal' })
    end,
  },
  {
    require('lspconfig').pyright.setup {
      settings = {
        pyright = {
          -- Using Ruff's import organizer
          disableOrganizeImports = true,
        },
        python = {
          analysis = {
            -- Ignore all files for analysis to exclusively use Ruff for linting
            ignore = { '*' },
          },
        },
      },
    },
  },
  { -- python specific keymaps
    vim.keymap.set({ 'n', 'i' }, '<m-i>', '<esc>i```{python}<cr>```<esc>O', { desc = '[i]nsert code chunk' }),
    vim.keymap.set({ 'n' }, '<leader>ci', ':split  term://ipython<cr>', { desc = '[c]ode repl [i]python' }),
  },
}
