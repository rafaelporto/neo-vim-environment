-- DAP configuration for Swift/iOS via codelldb + xcodebuild.nvim
-- Install adapter: :MasonInstall codelldb

local dap = require("dap")
local xcodebuild = require("xcodebuild.integrations.dap")

local codelldb_path = vim.fn.stdpath("data") .. "/mason/bin/codelldb"

xcodebuild.setup(codelldb_path)

dap.configurations.swift = {
    {
        name = "iOS App Debugger",
        type = "codelldb",
        request = "attach",
        program = xcodebuild.get_program_path,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        waitFor = true,
    },
}
