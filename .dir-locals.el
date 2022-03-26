;;; Directory Local Variables
;;; For more information see (info "(emacs) Directory Variables")

((nix-mode . (
              (nix-nixfmt-bin . "alejandra")
              (eval . (progn

                        (make-variable-buffer-local 'format-all--executable-table)

                        (setq format-all--executable-table
                              (let ((table (make-hash-table)))
                                (puthash 'nixfmt "alejandra" table)
                                table)
                              )

                        ))

              )))
