# herdr keybindings: the ctrl+b prefix stays; the keys follow vim and helix.
# Every action has a key. Where a key has a vim name it is the primary: v/s split (vim :vsplit/:split), y yank (copy
# mode), t tab, q quit (detach), m maximize (zoom), ; last pane. The tmux defaults stay as second keys.
# Schema: https://herdr.dev/llms.txt (config reference, keys.*). `herdr config check` validates the file.
{
  prefix = "ctrl+b";

  # session
  help = "prefix+?";
  settings = "prefix+comma";
  detach = [
    "prefix+q"
    "prefix+d"
  ];
  reload_config = "prefix+shift+r";
  open_notification_target = "prefix+o";
  toggle_sidebar = "prefix+b";
  goto = [
    "prefix+g"
    "prefix+space"
  ];

  # workspaces: w picks, ( ) step, shift+1..9 jump, shift+n/w/d new, rename, close
  workspace_picker = "prefix+w";
  new_workspace = "prefix+shift+n";
  rename_workspace = "prefix+shift+w";
  close_workspace = "prefix+shift+d";
  previous_workspace = "prefix+(";
  next_workspace = "prefix+)";
  switch_workspace = "prefix+shift+1..9";
  new_worktree = "prefix+shift+g";
  open_worktree = "prefix+shift+o";
  remove_worktree = "prefix+alt+d";

  # agents: alt+n/p step, alt+1..9 jump
  previous_agent = "prefix+alt+p";
  next_agent = "prefix+alt+n";
  focus_agent = "prefix+alt+1..9";

  # tabs (vim tabs): t new, n/p or ]/[ step, {/} move, 1..9 jump
  new_tab = [
    "prefix+t"
    "prefix+c"
  ];
  rename_tab = "prefix+shift+t";
  close_tab = "prefix+shift+x";
  previous_tab = [
    "prefix+p"
    "prefix+["
  ];
  next_tab = [
    "prefix+n"
    "prefix+]"
  ];
  move_tab_previous = "prefix+{";
  move_tab_next = "prefix+}";
  switch_tab = "prefix+1..9";

  # panes (vim windows): hjkl focus, shift+hjkl swap, alt+hjkl resize, v/s split, x close, m maximize
  focus_pane_left = "prefix+h";
  focus_pane_down = "prefix+j";
  focus_pane_up = "prefix+k";
  focus_pane_right = "prefix+l";
  swap_pane_left = "prefix+shift+h";
  swap_pane_down = "prefix+shift+j";
  swap_pane_up = "prefix+shift+k";
  swap_pane_right = "prefix+shift+l";
  resize_pane_left = "prefix+alt+h";
  resize_pane_down = "prefix+alt+j";
  resize_pane_up = "prefix+alt+k";
  resize_pane_right = "prefix+alt+l";
  resize_mode = "prefix+r";
  cycle_pane_next = "prefix+tab";
  cycle_pane_previous = "prefix+shift+tab";
  last_pane = "prefix+;";
  split_vertical = "prefix+v";
  split_horizontal = [
    "prefix+s"
    "prefix+minus"
  ];
  close_pane = [
    "prefix+x"
    "prefix+shift+q"
  ];
  zoom = [
    "prefix+m"
    "prefix+z"
  ];
  rename_pane = "prefix+shift+p";

  # text: y yank (copy mode), e edit the scrollback in $EDITOR, ctrl+l clear
  copy_mode = "prefix+y";
  edit_scrollback = "prefix+e";
  clear_pane = "prefix+ctrl+l";

  command = [
    {
      key = "prefix+backtick";
      type = "popup";
      command = ''exec "''${SHELL:-sh}"'';
      description = "scratch terminal";
      width = "80%";
      height = "80%";
    }
  ];
}
