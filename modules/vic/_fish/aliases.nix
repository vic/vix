{
  y = "EDITOR=d yazi";
  l = "exa -l";
  ll = "exa -l -@ --git";
  tree = "exa -T";
  # "." = "exa -g";
  ".." = "cd ..";
  vf = ''vim -c "lua Snacks.picker.files()"'';
  vg = ''vim -c "lua Snacks.picker.grep()"'';
  vr = ''vim -c "lua Snacks.picker.recent()"'';
}
