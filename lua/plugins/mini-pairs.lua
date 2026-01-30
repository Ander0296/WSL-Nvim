return {
  "nvim-mini/mini.pairs",
  event = "VeryLazy",
  opts = {
    modes = { insert = true, command = true, terminal = false },
    -- no hacer autopair si el siguiente caracter coincide con esto
    skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
    -- no hacer autopair si estás dentro de estos nodos de treesitter
    skip_ts = { "string" },
    -- no hacer autopair si el siguiente caracter es un cierre
    -- y hay más cierres que aperturas
    skip_unbalanced = true,
    -- mejor comportamiento con bloques de código en markdown
    markdown = true,
  },
  config = function(_, opts)
    require("mini.pairs").setup(opts)
  end,
}
