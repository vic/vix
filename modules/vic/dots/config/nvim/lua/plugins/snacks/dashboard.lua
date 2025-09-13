return {
  enabled = true;
  sections = {
    { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
    { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
    {
      icon = " ",
      title = "jj Status",
      section = "terminal",
      enabled = function()
        return Snacks.git.get_root() ~= nil
      end,
      cmd = "jj --ignore-working-copy show --no-patch --no-pager",
      height = 10,
      padding = 1,
      ttl = 5 * 60,
      indent = 3,
    },
    { pane = 2, section = "startup" },
    { pane = 2, section = "header" },
    {
      pane = 2,
      section = "terminal",
      cmd = "echo hola",
      height = 5,
      padding = 1,
    },
    { pane = 2, section = "keys", gap = 1, padding = 1 },
  },
}
