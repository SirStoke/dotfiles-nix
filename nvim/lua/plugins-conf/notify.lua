return {
  -- Useful status updates for LSP and notifications. Much much much less intrusive than nvim-notify
  'j-hui/fidget.nvim',
  keys = {
    {
      '<leader>un',
      function()
        require('fidget').clear()
      end,
      desc = 'Dismiss All Notifications',
    },
    {
      '<leader>uh',
      function()
        require('fidget').show_history()
      end,
      desc = 'Dismiss All Notifications',
    },
  },
  opts = {},
  init = function()
    vim.notify = require('fidget').notify
  end,
}
