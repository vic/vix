;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
(setq doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 14 :weight 'semi-light)
      doom-big-font (font-spec :family "JetBrainsMono Nerd Font" :size 24 :weight 'semi-light)
      doom-variable-pitch-font (font-spec :family "JetBrainsMono Nerd Font" :size 12)
      )
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-oksolar-light)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
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
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.


(use-package! lsp-mode
  :commands lsp
  :config
  (add-hook 'lsp-mode-hook 'lsp-ui-mode)
  :custom
  ;;(lsp-headerline-breadcrumb-enable t)
  (lsp-eldoc-render-all t)
  ;;(lsp-idle-delay 0.6)
  ;; enable / disable the hints as you prefer:
  ;;(lsp-inlay-hint-enable t)

;; These are optional configurations. See https://emacs-lsp.github.io/lsp-mode/page/lsp-rust-analyzer/#lsp-rust-analyzer-display-chaining-hints for a full list
  (lsp-rust-analyzer-display-lifetime-elision-hints-enable "skip_trivial")
  (lsp-rust-analyzer-display-chaining-hints t)
  (lsp-rust-analyzer-display-lifetime-elision-hints-use-parameter-names nil)
  (lsp-rust-analyzer-display-closure-return-type-hints t)
  (lsp-rust-analyzer-display-parameter-hints nil)
  (lsp-rust-analyzer-display-reborrow-hints nil)
  )

(use-package! lsp-ui
  :commands lsp-ui-mode
  :custom
  (lsp-ui-peek-always-show t)
  (lsp-ui-sideline-show-hover t)
  (lsp-ui-doc-enable t)
  )


(use-package! eee
  :custom
  (ee-terminal-command "wezterm")
  :config
  (ee-define "ee-jjui" (ee-get-project-dir-or-current-dir) "jjui;" nil ignore)
  (ee-define "ee-fish" (ee-get-project-dir-or-current-dir) "fish;" nil ignore)
  (ee-define "ee-nix-fmt" (ee-get-project-dir-or-current-dir) "nix fmt>&2;read;" nil ignore)
  (ee-define "ee-nix-check" (ee-get-project-dir-or-current-dir) "nix flake checl>&2;read;" nil ignore)
  (map! :leader
        (:prefix ("e" . "Execute")
         :desc "jjui" "j" #'ee-jjui
         :desc "fish" "t" #'ee-fish
         :desc "find" "f" #'ee-find
         :desc "grep" "g" #'ee-rg
         :desc "yazi" "d" #'ee-yazi
         (:prefix ("n" . "Nix")
           :desc "check" "c" #'ee-nix-check
           :desc "fmt" "f" #'ee-nix-fmt)
         ))
  )


(use-package! jujutsu
  :commands (jujutsu-status jujutsu-status-dispatch))

(use-package! gptel
  :config
  (setq vic/gptel-gh-backend
   ;; Github Models offers an OpenAI compatible API
   (gptel-make-openai "Github Models" ;Any name you want
     :host "models.inference.ai.azure.com"
     :endpoint "/chat/completions?api-version=2024-05-01-preview"
     :stream t
     :key (shell-command-to-string "vic-sops-get -a gh_models_pat")
     ;; :models '(claude-3.5-sonnet gpt-4o)
     ))

  (setq vic/gptel-gemini-backend
   (gptel-make-gemini "Gemini"
      :key (shell-command-to-string "vic-sops-get -a gemini_eco_key")
      :stream t))

  ;; (setq gptel-model 'gpt-4o)
  (setq gptel-backend vic/gptel-gh-backend)

  (map! :leader
        (:prefix ("G" . "GPT")
         :desc "gptel" "g" #'gptel
         :desc "gptel" "G" #'gptel-menu
         ))
  )

(use-package aider
  :config
  (setq aider-args '("--model" "sonnet"))
  (require 'aider-doom))


(use-package! copilot
  ;; :hook (prog-mode . copilot-mode)

  :config
  (add-to-list 'copilot-indentation-alist '(prog-mode 2))
  (add-to-list 'copilot-indentation-alist '(org-mode 2))
  (add-to-list 'copilot-indentation-alist '(text-mode 2))
  (add-to-list 'copilot-indentation-alist '(scala-mode 2))
  (add-to-list 'copilot-indentation-alist '(go-mode 2))
  (add-to-list 'copilot-indentation-alist '(rust-mode 2))
  (add-to-list 'copilot-indentation-alist '(closure-mode 2))
  (add-to-list 'copilot-indentation-alist '(emacs-lisp-mode 2)))


(defun copilot-complete-or-indent()
  (interactive)
  (if (copilot--overlay-visible)
      (copilot-accept-completion-by-word)
    (copilot-complete)))


(map! :nvir
      "<backtab>" 'copilot-complete-or-indent
      "<tab>" 'copilot-accept-completion
      "TAB" 'copilot-accept-completion
      "C-TAB" 'copilot-accept-completion-by-word
      "C-<tab>" 'copilot-accept-completion-by-word
      "C-n" 'copilot-next-completion
      "C-p" 'copilot-previous-completion)

(map! :leader :desc "Run Command" "SPC" 'execute-extended-command)

(map! :n :desc "Comment or uncomment" "C-/" 'comment-dwim)
(map! :n "U" 'evil-redo)
(map! :m "[ [" 'better-jumper-jump-backward)
(map! :m "] ]" 'better-jumper-jump-forward)


(setq god-global-mode -1)
(god-mode-all -1)
(map! :leader :desc "God Mode" "<escape>" 'god-execute-with-current-bindings)

(defun my-hl-line-range-function ()
  (let ((beg (save-excursion
           (back-to-indentation)
           (point)))
        (end (save-excursion
           (end-of-visual-line)
           (point))))
    (cons beg end)))

(setq hl-line-range-function #'my-hl-line-range-function)
(setq eldoc-echo-area-use-multiline-p 1)


;; from https://gist.github.com/yorickvP/6132f237fbc289a45c808d8d75e0e1fb
;; Set up wl-copy and wl-paste in terminal Emacs
(when (and (or server-mode (string= (getenv "XDG_SESSION_TYPE") "wayland"))
           (executable-find "wl-copy")
           (executable-find "wl-paste"))
  (defun my-wl-copy (text)
    "Copy with wl-copy if in terminal, otherwise use the original value of `interprogram-cut-function'."
    (if (display-graphic-p)
        (gui-select-text text)
      (let ((wl-copy-process
             (make-process :name "wl-copy"
                           :buffer nil
                           :command '("wl-copy")
                           :connection-type 'pipe)))
        (process-send-string wl-copy-process text)
        (process-send-eof wl-copy-process))))
  (defun my-wl-paste ()
    "Paste with wl-paste if in terminal, otherwise use the original value of `interprogram-paste-function'."
    (if (display-graphic-p)
        (gui-selection-value)
      (shell-command-to-string "wl-paste --no-newline")))
  (setq interprogram-cut-function #'my-wl-copy)
  (setq interprogram-paste-function #'my-wl-paste))
