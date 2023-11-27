return {
    "OmniSharp/omnisharp-vim",
    init = function()
        local home = os.getenv("HOME")
        vim.g.OmniSharp_server_path = home.."/.omnisharp/OmniSharp"
        vim.g.OmniSharp_server_use_net6 = 1
    end
}
