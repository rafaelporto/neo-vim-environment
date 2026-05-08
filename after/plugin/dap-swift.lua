-- DAP configuration for Swift/iOS via xcodebuild.nvim
-- Xcode 16+: codelldb is no longer required. xcodebuild.setup() handles the adapter.

local xcodebuild = require("xcodebuild.integrations.dap")

xcodebuild.setup()
