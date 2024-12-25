-- Map Ctrl + Insert to copy to + reg
vim.api.nvim_set_keymap('n', 'C-Insert', '"+y', { noremap = true })
vim.api.nvim_set_keymap('v', 'C-Insert', '"+y', { noremap = true })

-- Map Ctrl + Insert to copy to + reg
vim.api.nvim_set_keymap('n', 'S-Insert', '"+p', { noremap = true })
vim.api.nvim_set_keymap('v', 'S-Insert', '<C-r>+', { noremap = true })
