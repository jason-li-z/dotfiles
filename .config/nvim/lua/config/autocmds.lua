-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--
-- Auto-inject C++ Competitive Programming Template
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.cpp",
  callback = function()
    local template = {
      "#include <bits/stdc++.h>",
      "using namespace std;",
      "",
      "typedef long long ll;",
      "",
      "#define sz(x) (int)x.size()",
      "#define all(x) begin(x), end(x)",
      "#define print(msg) cout << msg << endl",
      "#define dbg(...) __f(#__VA_ARGS__, __VA_ARGS__)",
      "",
      "template <typename Arg1>",
      "void __f(const char* name, Arg1&& arg1) { cout << name << \" : \" << arg1 << endl; }",
      "template <typename Arg1, typename... Args>",
      "void __f(const char* names, Arg1&& arg1, Args&&... args) {",
      "    const char* comma = strchr(names + 1, ',');",
      "    cout.write(names, comma - names) << \" : \" << arg1 << \" | \";",
      "    __f(comma + 1, args...);",
      "}",
      "",
      "const ll MOD = 1e9 + 7;",
      "const ll INF = 1e9;",
      "",
      "int main() {",
      "    ios::sync_with_stdio(false);",
      "    cin.tie(nullptr);",
      "    return 0;",
      "}"
    }
    
    -- Insert the template into the current buffer
    vim.api.nvim_buf_set_lines(0, 0, -1, false, template)
    
    -- Drop the cursor on Line 26, Column 4 (Right inside int main(), below cin.tie)
--    vim.api.nvim_win_set_cursor(0, {26, 4})
    -- Automatically enter Insert mode so you don't waste a single keystroke
    --vim.cmd("startinsert")
  end,
})
