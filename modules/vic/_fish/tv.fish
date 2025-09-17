bind \t __tv_complete

function __tv_complete -d 'fish completion widget with tv'
    # modified from https://github.com/junegunn/fzf/wiki/Examples-(fish)#completion
    # As of 2.6, fish's "complete" function does not understand
    # subcommands. Instead, we use the same hack as __fish_complete_subcommand and
    # extract the subcommand manually.
    set -l cmd (commandline -co) (commandline -ct)

    switch $cmd[1]
        case env sudo
            for i in (seq 2 (count $cmd))
                switch $cmd[$i]
                    case '-*'
                    case '*=*'
                    case '*'
                        set cmd $cmd[$i..-1]
                        break
                end
            end
    end

    set -l cmd_lastw $cmd[-1]
    set cmd (string join -- ' ' $cmd)

    set -l complist (complete -C$cmd)
    set -l result

    # do nothing if there is nothing to select from
    test -z "$complist"; and return

    set -l compwc (echo $complist | wc -w)
    if test $compwc -eq 1
        # if there is only one option dont open fzf
        set result "$complist"
    else
        set result (string join -- \n $complist | column -t -l 2 -o \t |  tv --select-1 --no-status-bar --keybindings='tab="confirm_selection"' --inline  --input-header "$cmd" | string split -m 2 -f 1 \t | string trim --right)
    end

    set -l prefix (string sub -s 1 -l 1 -- (commandline -t))
    for i in (seq (count $result))
        set -l r $result[$i]
        switch $prefix
            case "'"
                commandline -t -- (string escape -- $r)
            case '"'
                if string match '*"*' -- $r >/dev/null
                    commandline -t -- (string escape -- $r)
                else
                    commandline -t -- '"'$r'"'
                end
            case '~'
                commandline -t -- (string sub -s 2 (string escape -n -- $r))
            case '*'
                commandline -t -- $r
        end
        commandline -i ' '
    end
    commandline -f repaint
end
