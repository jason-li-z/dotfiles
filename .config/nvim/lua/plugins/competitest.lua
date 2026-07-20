return {
  "xeluxee/competitest.nvim",
  dependencies = "MunifTanjim/nui.nvim",
  keys = {
    { "<leader>cr", "<cmd>CompetiTest run<CR>", desc = "Run CP Test Cases" },
    { "<leader>ca", "<cmd>CompetiTest add_testcase<CR>", desc = "Add CP Test Case" },
    { "<leader>ce", "<cmd>CompetiTest edit_testcase<CR>", desc = "Edit CP Test Case" },
    { "<leader>cp", "<cmd>CompetiTest receive problem<CR>", desc = "Receive CP Problem" },
    { "<leader>cc", "<cmd>CompetiTest receive contest<CR>", desc = "Receive CP Contest" },
  },
  config = function()
    require("competitest").setup({
      local_build = true,
      testcases_use_single_file = true, -- Keeps your folder clean
      runner_ui = {
        interface = "split",
      },
      -- C++ Compilation and Run commands (Adjust if using Python/Java)
      compile_command = {
        cpp = { exec = "g++", args = { "-O3", "-std=c++20", "-Wall", "-Wextra", "$(FNAME)", "-o", "$(FNOEXT)" } },
        python = { exec = "python3", args = { "-m", "py_compile", "$(FNAME)" } },
      },
      run_command = {
        cpp = { exec = "./$(FNOEXT)" },
        python = { exec = "python3", args = { "$(FNAME)" } },
      },
    })
  end,
}
