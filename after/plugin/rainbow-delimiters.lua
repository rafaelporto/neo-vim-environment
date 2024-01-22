local rainbow_delimiters = require 'rainbow-delimiters'

require('rainbow-delimiters.setup').setup {
    strategy = {
        [''] = rainbow_delimiters.strategy['global'],
        vim = rainbow_delimiters.strategy['local']
    },
    query = {
        [''] = 'rainbow-delimiters'
    },
    priority = {
        [''] = 110,
        lua = 210,
    },
    highlight = {
        'RainbowDelimiterGreen',
        'RainbowDelimiterYellow',
        'RainbowDelimiterBlue',
        'RainbowDelimiterViolet',
        'RainbowDelimiterCyan',
        'RainbowDelimiterOrange',
        'RainbowDelimiterRed',
    }
}
