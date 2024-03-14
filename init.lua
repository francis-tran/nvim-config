vim.g.base46_cache = vim.fn.stdpath "data" .. "/nvchad/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
    config = function()
      require "options"
    end,
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
require('lspconfig').jdtls.setup({on_attach = require("lsp-format").on_attach})

require'lspconfig'.eslint.setup{on_attach = require("lsp-format").on_attach}

require'lspconfig'.pyright.setup{on_attach = require("lsp-format").on_attach}

--Enable (broadcasting) snippet capability for completion
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

require'lspconfig'.html.setup {
  capabilities = capabilities,
  on_attach = require("lsp-format").on_attach,
}

-- https://github.com/creativenull/efmls-configs-nvim/blob/main/doc/SUPPORTED_LIST.md
-- Register linters and formatters per language
local eslint = require('efmls-configs.linters.eslint_d')
local prettier = require('efmls-configs.formatters.prettier_d')
local stylua = require('efmls-configs.formatters.stylua')
local pylint = require('efmls-configs.linters.pylint')
local black = require('efmls-configs.formatters.black')
local languages = {
  typescript = { eslint, prettier },
  java = { prettier },
  javascript = {eslint, prettier},
  html = { prettier },
  lua = { stylua },
  python = { black, pylint },
}

local efmls_config = {
  filetypes = vim.tbl_keys(languages),
  settings = {
    rootMarkers = { '.git/' },
    languages = languages,
  },
  init_options = {
    documentFormatting = true,
    documentRangeFormatting = true,
  },
}


require('lspconfig').efm.setup(vim.tbl_extend('force', efmls_config, {
  -- Pass your custom lsp config below like on_attach and capabilities
  --
  -- on_attach = on_attach,
  -- capabilities = capabilities,
}))

require("lsp-format").setup {}
