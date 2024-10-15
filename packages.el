;; -*- no-byte-compile: t; -*-
;; $doomdir/packages.el

(package! cobol-mode)

(package! just-mode)

(package! csv-mode)

(package! treesit-auto)
(package! evil-textobj-tree-sitter)

(package! lsp-tailwindcss :recipe (:host github :repo "merrickluo/lsp-tailwindcss"))

(package! super-save)
;(use-package! super-save)

(use-package rg
  :ensure t
  :config
  (rg-enable-default-bindings))

(package! copilot
  :recipe (:host github :repo "copilot-emacs/copilot.el" :files ("*.el" "dist")))
