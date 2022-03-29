;;; Directory Local Variables
;;; For more information see (info "(emacs) Directory Variables")

((nix-mode . (
              (nix-nixfmt-bin . "alejandra-quiet")
              (eval . (progn

                        (make-variable-buffer-local 'format-all--executable-table)

                        (setq format-all--executable-table
                              (let ((table (make-hash-table)))
                                (puthash 'nixfmt "alejandra-quiet" table)
                                table)
                              )

                        ))

              )))
