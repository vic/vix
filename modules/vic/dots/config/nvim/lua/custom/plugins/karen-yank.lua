return {
  {
    'tenxsoydev/karen-yank.nvim',
    config = function() -- This is the function that runs, AFTER loading
      require('karen-yank').setup {
        mappings = {
          -- karen controls the use of registers (and probably talks to the manager when things doesn't work as intended)
          -- map something like `<leader><leader>` if you use the plugin inverted
          karen = 'y',
          -- false: delete into black hole by default and use registers with karen key
          -- true: use registers by default and delete into black hole with karen key
          invert = false,
          -- disable all if `true` or a table of keymaps [possible values: {"s"|"S"|"d"|"D"|"c"|"C"|"x"|"X"|"p"|"P"|"y"|"Y"}]
          -- "s"/"S" is not mapped by default, due to it's common utilization for plugins like surround or hop
          disable = { 's', 'S' },
        },
        number_regs = {
          -- use number registers for yanks and cuts
          enable = true,
          deduplicate = {
            -- prevent populating multiple number registers with the same entries
            enable = true,
            -- will see `yD` pressed at the beginning of a line as a duplicate of `ydd` pressed in the same line
            ignore_whitespace = true,
          },
        },
      }
    end,
  },
}
