return {
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'canary',
    dependencies = {
      { 'zbirenbaum/copilot.lua' }, -- or github/copilot.vim
      { 'nvim-lua/plenary.nvim' }, -- for curl, log wrapper
    },
    build = 'make tiktoken', -- Only on MacOS or Linux
    opts = {},
    config = function(_, opts)
      local vmap = function(keys, func, desc)
        vim.keymap.set('x', keys, func, { desc = 'AI Copilot: ' .. desc })
      end

      local chat = require 'CopilotChat'
      local select = require 'CopilotChat.select'

      chat.setup(opts)

      vim.api.nvim_create_user_command('CopilotChatVisual', function()
        chat.open { selection = select.visual }
      end, { nargs = '*', range = true })

      vim.api.nvim_create_user_command('CopilotChatInline', function()
        chat.open {
          selection = select.visual,
          window = {
            layout = 'float',
            relative = 'cursor',
            width = 1,
            height = 0.4,
            row = 1,
          },
        }
      end, { nargs = '*', range = true })

      vmap('<leader>ac', ':CopilotChatVisual<cr>', '[A]I [C]hat')
      vmap('<leader>ai', ':CopilotChatInline<cr>', '[A]I [I]nline chat')
    end,
    -- See Commands section for default commands if you want to lazy load on them
  },
}
