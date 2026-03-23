{ vic, lib, ... }:
{
  vic.nvf.includes = [ vic.nvf._.mini ];

  # TODO:vic.nvf._.mini.vim.keymaps = [ ];

  vic.nvf._.mini.vim.mini =
    let
      mini = {
        ai = { };
        align = { };
        animate = { };
        #basics = {
        #  options.extra_ui = true;
        #  mappings.windows = true;
        #};
        bracketed = { };
        bufremove = { };
        #clue = { };
        #colors = true;
        comment = { };
        ##completion = { };
        cursorword = { };
        diff = { };
        doc = { };
        extra = true;
        files = { };
        fuzzy = { };
        #git = { };
        hipatterns = { };
        icons = { };
        indentscope = { };
        jump = { };
        jump2d = {
          labels = "lkjhasdfgpoiuyqwertbv0987654321cnxmz";
          view.dim = true;
        };
        map = { };
        misc = { };
        move = { };
        notify = { };
        operators = { };
        pairs = { };
        #pick = { };
        #sessions = { };
        #snippets = { };
        splitjoin = { };
        statusline = { };
        surround = { };
        tabline = { };
        trailspace = { };
        visits = { };
      };
    in
    lib.listToAttrs (
      lib.mapAttrsToList (name: setupOpts: {
        inherit name;
        value = {
          enable = true;
        }
        // (lib.optionalAttrs (builtins.isAttrs setupOpts) {
          inherit setupOpts;
        });
      }) mini
    );
}
