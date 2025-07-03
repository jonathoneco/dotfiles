return {
  'CopilotC-Nvim/CopilotChat.nvim',
  branch = 'main',
  cmd = 'CopilotChat',
  opts = function()
    local user = vim.env.USER or 'User'
    user = user:sub(1, 1):upper() .. user:sub(2)

    -- Get project-specific history path
    local cwd = vim.fn.getcwd()
    local project_name = vim.fn.fnamemodify(cwd, ':t')
    local history_path = vim.fn.stdpath 'data' .. '/copilot_chat_history/' .. project_name .. '/'

    -- Ensure history directory exists
    vim.fn.mkdir(history_path, 'p')

    -- Helper functions for named chat management
    local function get_saved_chats()
      local saved_chats = {}
      local handle = vim.loop.fs_scandir(history_path)
      if handle then
        while true do
          local name, file_type = vim.loop.fs_scandir_next(handle)
          if not name then
            break
          end
          if file_type == 'file' and name and type(name) == 'string' and name:match '%.json$' then
            local chat_name = name:gsub('%.json$', '')
            saved_chats[#saved_chats + 1] = chat_name
          end
        end
      end
      return saved_chats
    end

    local function save_named_chat()
      vim.ui.input({
        prompt = 'Save chat as: ',
      }, function(input)
        if input and input ~= '' then
          local safe_name = input:gsub('[^%w%-%_]', '_')
          vim.cmd('CopilotChatSave ' .. safe_name)
          vim.notify('Chat saved as: ' .. input, vim.log.levels.INFO)
        end
      end)
    end

    local function load_named_chat()
      local saved_chats = get_saved_chats()
      if #saved_chats == 0 then
        vim.notify('No saved chats found', vim.log.levels.WARN)
        return
      end

      vim.ui.select(saved_chats, {
        prompt = 'Select chat to load:',
      }, function(choice)
        if choice then
          vim.cmd('CopilotChatLoad ' .. choice)
          vim.notify('Chat loaded: ' .. choice, vim.log.levels.INFO)
        end
      end)
    end

    local function delete_named_chat()
      local saved_chats = get_saved_chats()
      if #saved_chats == 0 then
        vim.notify('No saved chats found', vim.log.levels.WARN)
        return
      end

      vim.ui.select(saved_chats, {
        prompt = 'Select chat to delete:',
      }, function(choice)
        if choice then
          vim.ui.input({
            prompt = 'Delete "' .. choice .. '"? (y/N): ',
          }, function(confirm)
            if confirm and confirm:lower() == 'y' then
              local filepath = history_path .. '/' .. choice .. '.json'
              local ok = os.remove(filepath)
              if ok then
                vim.notify('Chat deleted: ' .. choice, vim.log.levels.INFO)
              else
                vim.notify('Failed to delete chat', vim.log.levels.ERROR)
              end
            end
          end)
        end
      end)
    end

    return {
      auto_insert_mode = true,
      question_header = '  ' .. user .. ' ',
      answer_header = '  Copilot ',
      history_path = history_path,
      window = {
        width = 0.4,
      },
      model = 'claude-sonnet-4',
      save_named_chat = save_named_chat,
      load_named_chat = load_named_chat,
      delete_named_chat = delete_named_chat,
    }
  end,
  keys = {
    { '<c-s>', '<CR>', ft = 'copilot-chat', desc = 'Submit Prompt', remap = true },
    { '<leader>a', '', desc = '+ai', mode = { 'n', 'v' } },
    {
      '<leader>aa',
      function()
        local chat = require 'CopilotChat'
        chat.toggle()
      end,
      desc = 'Toggle (CopilotChat)',
      mode = { 'n', 'v' },
    },
    {
      '<leader>ax',
      function()
        return require('CopilotChat').reset()
      end,
      desc = 'Clear (CopilotChat)',
      mode = { 'n', 'v' },
    },
    {
      '<leader>as',
      function()
        require('CopilotChat').config.save_named_chat()
      end,
      desc = 'Save Chat (CopilotChat)',
      mode = { 'n', 'v' },
    },
    {
      '<leader>al',
      function()
        require('CopilotChat').config.load_named_chat()
      end,
      desc = 'Load Chat (CopilotChat)',
      mode = { 'n', 'v' },
    },
    {
      '<leader>ad',
      function()
        require('CopilotChat').config.delete_named_chat()
      end,
      desc = 'Delete Chat (CopilotChat)',
      mode = { 'n', 'v' },
    },
    {
      '<leader>aq',
      function()
        vim.ui.input({
          prompt = 'Quick Chat: ',
        }, function(input)
          if input ~= '' then
            require('CopilotChat').ask(input)
          end
        end)
      end,
      desc = 'Quick Chat (CopilotChat)',
      mode = { 'n', 'v' },
    },
    {
      '<leader>ap',
      function()
        require('CopilotChat').select_prompt()
      end,
      desc = 'Prompt Actions (CopilotChat)',
      mode = { 'n', 'v' },
    },
  },
  config = function(_, opts)
    local chat = require 'CopilotChat'

    vim.api.nvim_create_autocmd('BufEnter', {
      pattern = 'copilot-chat',
      callback = function()
        vim.opt_local.relativenumber = false
        vim.opt_local.number = false
      end,
    })

    chat.setup(opts)

    -- Store helper functions in chat config for keymap access
    chat.config.save_named_chat = opts.save_named_chat
    chat.config.load_named_chat = opts.load_named_chat
    chat.config.delete_named_chat = opts.delete_named_chat
  end,
}
