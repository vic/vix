;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Victor Hugo Borja"
      user-mail-address "vborja@apache.org")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font (font-spec :family "Victor Mono" :size 16)
      doom-big-font (font-spec :family "Victor Mono" :size 24)
      doom-variable-pitch-font (font-spec :family "Victor Mono" :size 10))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-challenger-deep)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(setq evil-move-cursor-back nil)
(setq lsp-enable-file-watchers nil)

(map! :n "U" #'evil-redo)

(map! :leader
  "SPC" #'execute-extended-command
  "b SPC" #'switch-to-buffer
  "b w" #'switch-to-buffer-other-window
  "b t" #'switch-to-buffer-other-tab
  "t t" #'treemacs
  )

(map! :ir (kbd "<backtab>") #'company-complete)

(map! :n (kbd "C-;") #'iedit-mode)

(map! :map iedit-mode-occurrence-keymap :n
  "q" #'iedit-quit
  "n" #'iedit-next-occurrence
  "p" #'iedit-prev-occurrence
  "t" #'iedit-toggle-selection
  "f" #'iedit-mode-toggle-on-function
  "H" #'iedit-help-for-occurrences
  "r" #'iedit-replace-occurrences
  "@" #'iedit-number-occurrences
  "V" #'iedit-restrict-current-line
  "F" #'iedit-restrict-function
  "R" #'iedit-restrict-region
  "C" #'iedit-show/hide-context-lines
  "O" #'iedit-show/hide-occurrence-lines
  "K" #'iedit-expand-up-to-occurrence
  "J" #'iedit-expand-down-to-occurrence
  "#" #'iedit-increment-occurrences
  )

(use-package! evil-god-state
  :defer t
  :defer-incrementally god-mode
  :commands (evil-execute-in-god-state evil-god-state-bail)

  :init
  (evil-define-key 'god global-map [escape] 'evil-god-state-bail)
  (map! :leader :nm "<escape>" #'evil-execute-in-god-state :desc "God mode")

  :config
  (when (featurep 'diminish)
    (add-hook 'evil-god-state-entry-hook (lambda () (diminish 'god-local-mode)))
    (add-hook 'evil-god-state-exit-hook (lambda () (diminish-undo 'god-local-mode)))
    )
  )

(use-package! doom-golden-ratio
  :defer t
  :commands (doom-golden-ratio-mode)
  :init
  (map! :leader :nm "t G" #'doom-golden-ratio-mode))

(after! doom-golden-ratio
  (doom-golden-ratio-mode))
