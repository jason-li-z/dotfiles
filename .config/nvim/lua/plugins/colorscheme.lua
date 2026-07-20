return {
  {
    "e-ink-colorscheme/e-ink.nvim",
    priority = 1000,
    config = function()
      require("e-ink").setup()

      local function apply_highlights()
        local set_hl = vim.api.nvim_set_hl
        local is_dark = vim.o.background == "dark"

        -- Light: dark ink on paper
        -- Dark:  luminous ink on dark canvas
        local c = is_dark
            and {
              purple = "#b48eff", -- keywords, control flow
              blue = "#70b0e0", -- variables, identifiers
              teal = "#4ecbb8", -- types, namespaces
              green = "#88c060", -- comments
              olive = "#c8a84b", -- numbers, booleans
              rose = "#e07890", -- constants, constructors
              orange = "#d4845a", -- strings
              slate = "#9aaabb", -- operators, delimiters
              ink = "#d4d4d4", -- default text
              faded = "#7a7a7a", -- punctuation
            }
          or {
            purple = "#8b5fc7",
            blue = "#4078a8",
            teal = "#2a8a7a",
            green = "#5a8a3c",
            olive = "#7d6b2d",
            rose = "#b05062",
            orange = "#a65d3f",
            slate = "#6b7b8d",
            ink = "#3a3a3a",
            faded = "#8a8a8a",
          }

        -- Keywords
        set_hl(0, "@keyword", { fg = c.purple })
        set_hl(0, "@keyword.return", { fg = c.purple })
        set_hl(0, "@keyword.function", { fg = c.purple })
        set_hl(0, "@keyword.operator", { fg = c.purple })
        set_hl(0, "@conditional", { fg = c.purple })
        set_hl(0, "@repeat", { fg = c.purple })
        set_hl(0, "@include", { fg = c.purple })
        set_hl(0, "@exception", { fg = c.purple })

        -- Functions
        set_hl(0, "@function", { fg = c.blue, bold = true })
        set_hl(0, "@function.call", { fg = c.blue })
        set_hl(0, "@function.builtin", { fg = c.blue })
        set_hl(0, "@method", { fg = c.blue })
        set_hl(0, "@method.call", { fg = c.blue })

        -- Variables
        set_hl(0, "@variable", { fg = c.ink })
        set_hl(0, "@variable.builtin", { fg = c.blue, italic = true })
        set_hl(0, "@parameter", { fg = c.ink })

        -- Types
        set_hl(0, "@type", { fg = c.teal })
        set_hl(0, "@type.builtin", { fg = c.teal })
        set_hl(0, "@type.definition", { fg = c.teal })
        set_hl(0, "@storageclass", { fg = c.teal })

        -- Strings
        set_hl(0, "@string", { fg = c.orange })
        set_hl(0, "@string.escape", { fg = c.rose })
        set_hl(0, "@string.regex", { fg = c.rose })

        -- Numbers / booleans
        set_hl(0, "@number", { fg = c.olive })
        set_hl(0, "@float", { fg = c.olive })
        set_hl(0, "@boolean", { fg = c.olive, italic = true })

        -- Constants
        set_hl(0, "@constant", { fg = c.rose, bold = true })
        set_hl(0, "@constant.builtin", { fg = c.rose, bold = true })
        set_hl(0, "@constant.macro", { fg = c.rose, bold = true })

        -- Properties
        set_hl(0, "@property", { fg = c.blue })
        set_hl(0, "@field", { fg = c.blue })

        -- Operators / punctuation
        set_hl(0, "@operator", { fg = c.slate })
        set_hl(0, "@punctuation.bracket", { fg = c.faded })
        set_hl(0, "@punctuation.delimiter", { fg = c.faded })
        set_hl(0, "@punctuation.special", { fg = c.slate })

        -- Comments
        set_hl(0, "@comment", { fg = c.green, italic = true })
        set_hl(0, "@comment.documentation", { fg = c.green, italic = true })

        -- Tags
        set_hl(0, "@tag", { fg = c.rose })
        set_hl(0, "@tag.attribute", { fg = c.orange, italic = true })
        set_hl(0, "@tag.delimiter", { fg = c.faded })

        -- Constructor / Preprocessor / Namespace
        set_hl(0, "@constructor", { fg = c.teal })
        set_hl(0, "@preproc", { fg = c.purple, italic = true })
        set_hl(0, "@define", { fg = c.purple, italic = true })
        set_hl(0, "@namespace", { fg = c.teal })

        -- Classic Vim fallbacks
        set_hl(0, "Comment", { fg = c.green, italic = true })
        set_hl(0, "String", { fg = c.orange })
        set_hl(0, "Keyword", { fg = c.purple })
        set_hl(0, "Function", { fg = c.blue })
        set_hl(0, "Type", { fg = c.teal })
        set_hl(0, "Number", { fg = c.olive })
        set_hl(0, "Boolean", { fg = c.olive, italic = true })
        set_hl(0, "Constant", { fg = c.rose, bold = true })
        set_hl(0, "Operator", { fg = c.slate })
        set_hl(0, "Identifier", { fg = c.ink })
        set_hl(0, "PreProc", { fg = c.purple, italic = true })
        set_hl(0, "Include", { fg = c.purple })
        set_hl(0, "Statement", { fg = c.purple })
        set_hl(0, "Conditional", { fg = c.purple })
        set_hl(0, "Repeat", { fg = c.purple })
        set_hl(0, "Special", { fg = c.slate })
        set_hl(0, "Delimiter", { fg = c.faded })
      end

      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "e-ink",
        callback = apply_highlights,
      })

      -- Also re-apply when background changes (e.g. :set background=dark)
      vim.api.nvim_create_autocmd("OptionSet", {
        pattern = "background",
        callback = function()
          if vim.g.colors_name == "e-ink" then
            apply_highlights()
          end
        end,
      })

      vim.cmd.colorscheme("e-ink")
      vim.opt.background = "dark" -- change to "dark" to use dark mode
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "e-ink",
    },
  },
}
