return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = {
            "/run/current-system/sw/bin/clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=Google",
          },
        },
      },
    },
  },
}
