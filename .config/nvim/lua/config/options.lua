-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.guifont = "Departure Mono:h9:#e-subpixelantialias:#h-none"
vim.opt.linespace = 2

if vim.g.neovide then
  --  vim.g.neovide_opacity = 0.95
  --  vim.g.neovide_window_blurred = true

  -- Smooth scrolling and animation speeds
  vim.g.neovide_scroll_animation_length = 0.3
  vim.g.neovide_cursor_animation_length = 0.05
  vim.g.neovide_cursor_trail_size = 0.8

  -- Cursor particle effects (Options: "railgun", "torpedo", "pixiedust", "sonicboom", "ripple", "wireframe")
  --  vim.g.neovide_cursor_vfx_mode = "railgun"
  --  vim.g.neovide_cursor_vfx_opacity = 200.0
  --  vim.g.neovide_cursor_vfx_particle_lifetime = 1.2

  -- Performance & UX
  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_refresh_rate = 144
  vim.g.neovide_remember_window_size = true

  -- Keybinds for scaling (Zoom In/Out like a normal IDE)
  vim.keymap.set({ "n", "v" }, "<C-=>", function()
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1
  end)
  vim.keymap.set({ "n", "v" }, "<C-->", function()
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1
  end)
  vim.keymap.set({ "n", "v" }, "<C-0>", function()
    vim.g.neovide_scale_factor = 1.0
  end)

  vim.g.neovide_text_gamma = 0.8
  vim.g.neovide_text_contrast = 0.0

  -- OS Clipboard mappings for Neovide GUI
  if vim.fn.has("mac") == 1 then
    vim.keymap.set({ "n", "v" }, "<D-c>", '"+y', { noremap = true })
    vim.keymap.set({ "n", "v" }, "<D-v>", '"+p', { noremap = true })
    vim.keymap.set({ "i", "c" }, "<D-v>", "<C-R>+", { noremap = true })
  else
    vim.keymap.set({ "n", "v" }, "<C-S-c>", '"+y', { noremap = true })
    vim.keymap.set({ "n", "v" }, "<C-S-v>", '"+p', { noremap = true })
    vim.keymap.set({ "i", "c" }, "<C-S-v>", "<C-R>+", { noremap = true })
  end
end
