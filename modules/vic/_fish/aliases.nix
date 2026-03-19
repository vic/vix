{
  y = "EDITOR=d yazi";
  l = "exa -l";
  ll = "exa -l -@ --git";
  tree = "exa -T";
  # "." = "exa -g";
  ".." = "cd ..";
  vs = ''nvim -c "lua Snacks.picker.smart()"'';
  vf = ''nvim -c "lua Snacks.picker.files()"'';
  vg = ''nvim -c "lua Snacks.picker.grep()"'';
  vr = ''nvim -c "lua Snacks.picker.recent()"'';
  vd = ''nvim -c "DiffEditor $left $right $output"'';
  vt = ''nvim -c ":Tv"'';
  v0 = ''nvim -c "'0"'';
  v1 = ''nvim -c "'1"'';
  v2 = ''nvim -c "'2"'';
  vl = "v0"; # vi latest
  av = "astrovim";
  lv = "lazyvim";
  vu = "vim-gui";
  au = "astrovim-gui";
  lu = "lazyvim-gui";
  vul = "vu0";
  vu0 = ''vu -c "'0"'';
  vu1 = ''vu -c "'1"'';
  vu2 = ''vu -c "'2"'';
}
