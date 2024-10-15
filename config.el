;; config.el -*- lexical-binding: t; -*-

(use-package! treesit-auto
  :config
  (global-treesit-auto-mode))

(use-package! typescript-ts-mode
  :mode (("\\.ts\\'" . typescript-ts-mode)
         ("\\.tsx\\'" . tsx-ts-mode))
  :config
  (add-hook! '(typescript-ts-mode-hook tsx-ts-mode-hook) #'lsp!))

(after! projectile
  (projectile-register-project-type 'bun
                                    '("bun.lockb")
                                    :project-file "package.json"
                                    :compile "bun run build"
                                    :test "bun run test"
                                    :test-prefix ".test"
                                    :src-dir "src/"
                                    :configure "bun install"
                                    :run "bun run serve"))


(after! projectile
  (map! :localleader
        :map projectile-mode-map
        "p" #'projectile-project-name))

(after! projectile
  (projectile-register-project-type 'pnpm
                                    '("pnpm-lock.yaml")
                                    :project-file "package.json"
                                    :compile "pnpm run build"
                                    :test "pnpm run test"
                                    :test-prefix ".test"
                                    :src-dir "src/"
                                    :configure "pnpm install"
                                    :run "pnpm run serve"))

(after! projectile
  (projectile-register-project-type 'dotnet
                                    '("*.csproj")
                                    :project-file "*.csproj"
                                    :compile "dotnet build"
                                    :test "dotnet test"
                                    :test-prefix ".test"
                                    :src-dir ""
                                    :configure "dotnet restore"))

(add-hook
 'elixir-mode-hook
 (lambda ()
   (push '(">=" . ?\u2265) prettify-symbols-alist)
   (push '("<=" . ?\u2264) prettify-symbols-alist)
   (push '("!=" . ?\u2260) prettify-symbols-alist)
   (push '("==" . ?\u2A75) prettify-symbols-alist)
   (push '("=~" . ?\u2245) prettify-symbols-alist)
   (push '("<-" . ?\u2190) prettify-symbols-alist)
   (push '("->" . ?\u2192) prettify-symbols-alist)
   (push '("<-" . ?\u2190) prettify-symbols-alist)
   (push '("|>" . ?\u25B7) prettify-symbols-alist)))

(setq lsp-elixir-fetch-deps t)
(setq lsp-elixir-suggest-specs t)
(setq lsp-elixir-signature-after-complete t)
(setq lsp-elixir-enable-test-lenses t)
(after! lsp-mode
  (setq lsp-elixir-local-server-command "/etc/profiles/per-user/zell/bin/elixir-ls"))
(use-package lsp-mode
  :config
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\.node_modules\\'")
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]deps\\'")
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\].data\\'")
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\].direnv\\'")
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\].elixir_ls\\'")
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\].local\\'")
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]_build\\'"))

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Zoe Gagnon"
      user-mail-address "zoe@zgagnon.com")

(use-package! lsp-tailwindcss)

(setq read-process-output-max (* 1024 1024))
(setq gc-cons-threshold 100000000)

(after! org
  (super-save-mode +1))

(setq auto-save-default nil)

(setq projectile-generic-command "fd --type --print0")
(setq projectile-require-project-root nil)

(setq doom-theme 'doom-one)

(after! persp-mode
  ;; alternative, non-fancy version which only centers the output of +workspace--tabline
  (defun workspaces-formatted ()
    (+doom-dashboard--center (frame-width) (+workspace--tabline)))

  (defun hy/invisible-current-workspace ()
    "The tab bar doesn't update when only faces change (i.e. the
current workspace), so we invisibly print the current workspace
name as well to trigger updates"
    (propertize (safe-persp-name (get-current-persp)) 'invisible t))

  (customize-set-variable 'tab-bar-format '(workspaces-formatted tab-bar-format-align-right hy/invisible-current-workspace))

  ;; don't show current workspaces when we switch, since we always see them
  (advice-add #'+workspace/display :override #'ignore)
  ;; same for renaming and deleting (and saving, but oh well)
  (advice-add #'+workspace-message :override #'ignore))

;; need to run this later for it to not break frame size for some reason
(run-at-time nil nil (cmd! (tab-bar-mode +1)))

(custom-set-faces!
  '(+workspace-tab-face :inherit default :family "Jost" :height 135)
  '(+workspace-tab-selected-face :inherit (highlight +workspace-tab-face)))

(after! persp-mode
  (defun workspaces-formatted ()
    ;; fancy version as in screenshot
    (+doom-dashboard--center (frame-width)
                             (let ((names (or persp-names-cache nil))
                                   (current-name (safe-persp-name (get-current-persp))))
                               (mapconcat
                                #'identity
                                (cl-loop for name in names
                                         for i to (length names)
                                         collect
                                         (concat (propertize (format " %d" (1+ i)) 'face
                                                             `(:inherit ,(if (equal current-name name)
                                                                             '+workspace-tab-selected-face
                                                                           '+workspace-tab-face)
                                                               :weight bold))
                                                 (propertize (format " %s " name) 'face
                                                             (if (equal current-name name)
                                                                 '+workspace-tab-selected-face
                                                               '+workspace-tab-face))))
                                " ")))))
;; other persp-mode related configuration


(setq doom-font (font-spec :family "FiraCode Nerd Font" :size 18 :weight 'medium)
      doom-variable-pitch-font (font-spec :family "FiraCode Nerd Font" :size 18)
      doom-symbol-font (font-spec :family "FiraCode Nerd Font" :size 18)
      doom-serif-font (font-spec :family "FiraCode Nerd Font" :size 18))

(setq display-line-numbers-type t)
(setq-default tab-width 2)
(global-visual-line-mode 1)
(if (display-graphic-p)
    (progn
      (setq initial-frame-alist
            '((tool-bar-lines . 0)
              (width . 200)
              (height . 400)))))





(setq org-directory "~/org/")


(custom-set-faces!
  `(org-level-1 :family "Luminari" :height 400)
  `(org-level-2 :family "Cochin" :height 300)
  `(org-level-3 :family "Rockwell" :height 200)
  `(org-level-4 :family "Rockwell" :height 150)
  `(org-level-5 :family "Rockwell" :height 150)
  `(org-level-6 :family "Rockwell" :height 150))


(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("<tab>" . 'copilot-accept-completion)
              ("TAB" . 'copilot-accept-completion)
              ("C-TAB" . 'copilot-accept-completion-by-word)
              ("C-<tab>" . 'copilot-accept-completion-by-word)))
(defvar universal-indent 2)

(after! (evil copilot)
  (add-to-list 'copilot-indentation-alist '(elixir-mode universal-indent)))
