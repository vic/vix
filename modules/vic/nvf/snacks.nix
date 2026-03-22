{ vic, lib, ... }:
{
  vic.nvf.includes = [ vic.nvf._.snacks ];
  vic.nvf._.snacks =
    { mine }:
    {
      vim.utility.snacks-nvim = {
        enable = true;
        setupOpts = {
          dashboard.enabled = true;
          dashboard.preset = lib.optionalAttrs mine {
            header = builtins.readFile ./header.txt;
          };
          explorer.enabled = true;
          input.enabled = true;
          notifier.enabled = true;
          picker.enabled = true;
          quickfile.enabled = true;
          scope.enabed = true;
          scroll.enabled = true;
          statuscolumn.enabled = true;
          words.enabled = true;
        };
      };
    };
}
