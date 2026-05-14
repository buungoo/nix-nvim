return {
  "nvim-dap-ui",
  category = "core",
  keys = {
    { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle Debug UI" },
  },
  before = function()
    vim.cmd.packadd("nvim-nio")
  end,
  after = function()
    local dapui = require("dapui")
    dapui.setup()

    -- Automatically open/close UI when debugging starts/stops
    local dap = require("dap")
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end
  end,
}
