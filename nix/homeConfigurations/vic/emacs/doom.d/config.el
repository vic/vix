;;; $DOOMDIR/stardew valleyconfig.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!
(setq custom-file "/hk/dots/emacs.d/custom.el")
(add-to-list 'auth-sources "/hk/dots/emacs.d/authinfo")


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
(setq doom-theme 'doom-dracula)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'normal)


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
      "b TAB" #'switch-to-next-buffer
      "b <backtab>" #'switch-to-prev-buffer
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

(map! (:when IS-MAC :g "s-[" #'evil-jump-backward
     "s-]" #'evil-jump-forward
    ))

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

;; ;; Vertical window divider
;; (use-package! frame
;;   :init
;;   ;; Make sure new frames use window-divider
;;   (add-hook 'before-make-frame-hook 'window-divider-mode)
;;   :config
;;   (setq-default default-frame-alist
;;                 (append (list
;;                          ;; '(font . "SF Mono:style=medium:size=15") ;; NOTE: substitute whatever font you prefer here
;;                          '(internal-border-width . 20)
;;                          '(left-fringe    . 0)
;;                          '(right-fringe   . 0)
;;                          '(tool-bar-lines . 0)
;;                          '(menu-bar-lines . 0)
;;                          '(vertical-scroll-bars . nil))))
;;   (setq-default window-resize-pixelwise t)
;;   (setq-default frame-resize-pixelwise t)
;;   :custom
;;   (window-divider-default-right-width 12)
;;   (window-divider-default-bottom-width 1)
;;   (window-divider-default-places 'right-only)
;;   (window-divider-mode t))


;; (use-package! bespoke-themes
;;   :defer t
;;   :commands (bespoke/dark-theme bespoke/toggle-theme)
;;   :config
;;   ;; Set evil cursor colors
;;   (setq bespoke-set-evil-cursors t)
;;   ;; Set use of italics
;;   (setq bespoke-set-italic-comments t
;;         bespoke-set-italic-keywords t)
;;   ;; Set variable pitch
;;   (setq bespoke-set-variable-pitch t)
;;   ;; Set initial theme variant

;;   (setq bespoke-set-theme 'dark)
;;   ;; Load theme
;;   (load-theme 'bespoke t))

(set-formatter! 'alejandra "alejandra-quiet" :modes '(nix-mode))


;; accept completion from copilot and fallback to company
(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (("C-TAB" . 'copilot-complete)
         :map copilot-completion-map
         ("<backtab>" . 'copilot-previous-completion)
         ("<tab>" . 'copilot-next-completion)
         ("C-w" . 'copilot-accept-completion-by-word)
         ("C-l" . 'copilot-accept-completion-by-line)
         ("C-e" . 'copilot-accept-completion)
         ("C-d" . 'copilot-clear-overlay)
          ))

(use-package! emacs-mini-frame
  :defer t
  :commands (mini-frame-mode)
  :init (mini-frame-mode 1))

(toggle-frame-maximized)
(doom-golden-ratio-mode 1)
