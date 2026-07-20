return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = vim.tbl_filter(function(pkg)
        return not vim.tbl_contains({ "clangd", "lua-language-server", "cpplint" }, pkg)
      end, opts.ensure_installed or {})
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = vim.tbl_filter(function(server)
        return not vim.tbl_contains({ "clangd", "lua_ls" }, server)
      end, opts.ensure_installed or {})
      opts.automatic_installation = { exclude = { "clangd", "lua_ls" } }
    end,
  },
  {
    "p00f/clangd_extensions.nvim",
    optional = true,
    opts = {},
  },
}
