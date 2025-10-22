;;; biscotty-theme.el --- Tonsky-compliant restrained syntax highlighting

;; Copyright (C) 2024

;; Author: Claude & Zell
;; Version: 1.0
;; Keywords: faces, themes
;; URL: https://tonsky.me/blog/syntax-highlighting/

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;;; Commentary:

;; Biscotty is a Tonsky-compliant color scheme that embraces restraint.
;; Following the principle "if everything is highlighted, nothing is highlighted",
;; this theme uses only 5 carefully chosen colors:
;;
;; - Strings: Muted teal-green (#2d7f6f)
;; - Numbers: Terracotta coral (#c85e47)
;; - Constants: Dusty purple (#8b5a9e)
;; - Comments: Steel blue (#5276a1) - BOLD, not dimmed!
;; - Definitions: Caramel brown (#9d6b42)
;;
;; What's NOT highlighted (uses default foreground):
;; - Language keywords (if, class, function, etc.)
;; - Variable names
;; - Function calls
;;
;; Perfect for tty/SSH use with strong contrast ratios.

;;; Code:

(deftheme biscotty
  "Tonsky-compliant restrained syntax highlighting for tty warriors")

(let ((class '((class color) (min-colors 89)))
      ;; Base colors - warm peachy-cream background with strong contrast
      (bg-primary   "#f5ede5")  ; Warm peachy-cream - less green, more beige
      (bg-secondary "#ede4d8")  ; Slightly darker for subtle contrast
      (bg-alternate "#e5d9cc")  ; For selections/regions
      (bg-highlight "#ddd0c0")  ; For current line

      ;; Foreground colors
      (fg-primary   "#3a3a3a")  ; Dark charcoal - strong contrast for SSH
      (fg-dim       "#8a8a8a")  ; Dimmed for punctuation
      (fg-cursor    "#5276a1")  ; Steel blue cursor

      ;; Line numbers
      (line-number      "#a0a0a0")
      (line-number-cur  "#3a3a3a")

      ;; THE TONSKY FIVE - only these get color! (terminal-safe 256-color palette)
      (color-strings      "#00875f")  ; Terminal teal-green
      (color-numbers      "#d14830")  ; Vibrant terracotta
      (color-constants    "#7a4a94")  ; Deep dusty purple
      (color-comments     "#3d5f9a")  ; Deep steel blue
      (color-definitions  "#d7875f")  ; Warm peachy-orange

      ;; UI colors (not syntax highlighting)
      (ui-match       "#d14830")  ; Use number color for matches
      (ui-search      "#7a4a94")  ; Use constant color for search
      (ui-warning     "#d14830")  ; Use number color
      (ui-error       "#a03030")  ; Darker red for errors
      (ui-success     "#00875f")  ; Use string color

      ;; Mode line
      (modeline-bg "#3a3a3a")
      (modeline-fg "#f5ede5")
      (modeline-inactive-bg "#d0ccc0")
      (modeline-inactive-fg "#666666"))

  (custom-theme-set-faces
   'biscotty

   ;; ============================================================
   ;; BASE FACES - The foundation
   ;; ============================================================
   `(default ((,class (:background ,bg-primary :foreground ,fg-primary))))
   `(cursor ((,class (:background ,fg-cursor))))
   `(region ((,class (:background ,bg-alternate))))
   `(highlight ((,class (:background ,bg-highlight))))
   `(hl-line ((,class (:background ,bg-secondary))))
   `(fringe ((,class (:background ,bg-primary :foreground ,line-number))))
   `(border ((,class (:foreground ,fg-dim))))
   `(vertical-border ((,class (:foreground ,fg-dim))))

   ;; Links and buttons - use number color to match paths
   `(button ((,class (:foreground ,color-numbers :underline t))))
   `(link ((,class (:foreground ,color-numbers :underline t))))
   `(link-visited ((,class (:foreground ,color-numbers :underline t))))

   ;; ============================================================
   ;; FONT LOCK FACES - Tonsky's restrained approach
   ;; ============================================================

   ;; HIGHLIGHTED (the chosen 5)
   `(font-lock-string-face ((,class (:foreground ,color-strings :weight bold :slant italic))))
   `(font-lock-number-face ((,class (:foreground ,color-numbers :weight bold))))
   `(font-lock-constant-face ((,class (:foreground ,color-constants :weight bold))))
   `(font-lock-function-name-face ((,class (:foreground ,color-definitions :weight bold :slant italic))))
   `(font-lock-comment-face ((,class (:foreground ,color-comments :weight bold))))
   `(font-lock-doc-face ((,class (:foreground ,color-comments :weight bold))))

   ;; NOT HIGHLIGHTED (use default foreground) - Tonsky principle!
   `(font-lock-keyword-face ((,class (:foreground ,fg-primary))))
   `(font-lock-builtin-face ((,class (:foreground ,fg-primary))))
   `(font-lock-variable-name-face ((,class (:foreground ,fg-primary))))
   `(font-lock-type-face ((,class (:foreground ,fg-primary))))

   ;; Warning face gets color for visibility
   `(font-lock-warning-face ((,class (:foreground ,ui-warning :weight bold))))

   ;; ============================================================
   ;; LINE NUMBERS
   ;; ============================================================
   `(line-number ((,class (:foreground ,line-number :background ,bg-primary))))
   `(line-number-current-line ((,class (:foreground ,line-number-cur :background ,bg-secondary :weight bold))))

   ;; ============================================================
   ;; SEARCH AND MATCH
   ;; ============================================================
   `(isearch ((,class (:background ,ui-search :foreground ,bg-primary :weight bold))))
   `(lazy-highlight ((,class (:background ,bg-highlight))))
   `(match ((,class (:foreground ,ui-match :weight bold))))
   `(show-paren-match ((,class (:foreground ,ui-match :weight bold :underline t))))
   `(show-paren-mismatch ((,class (:background ,ui-error :foreground ,bg-primary))))

   ;; ============================================================
   ;; MODE LINE
   ;; ============================================================
   `(mode-line ((,class (:background ,modeline-bg :foreground ,modeline-fg :box (:line-width 1 :color ,fg-dim)))))
   `(mode-line-inactive ((,class (:background ,modeline-inactive-bg :foreground ,modeline-inactive-fg :box (:line-width 1 :color ,fg-dim)))))

   ;; ============================================================
   ;; ORG MODE
   ;; ============================================================
   `(org-level-1 ((,class (:foreground ,color-definitions :weight bold :height 1.3))))
   `(org-level-2 ((,class (:foreground ,color-definitions :weight bold :height 1.2))))
   `(org-level-3 ((,class (:foreground ,color-definitions :weight bold :height 1.1))))
   `(org-level-4 ((,class (:foreground ,color-definitions :weight bold))))
   `(org-level-5 ((,class (:foreground ,fg-primary :weight bold))))
   `(org-level-6 ((,class (:foreground ,fg-primary :weight bold))))
   `(org-level-7 ((,class (:foreground ,fg-primary :weight bold))))
   `(org-level-8 ((,class (:foreground ,fg-primary :weight bold))))
   `(org-code ((,class (:foreground ,color-constants))))
   `(org-block ((,class (:background ,bg-secondary :foreground ,fg-primary :extend t))))
   `(org-block-begin-line ((,class (:foreground ,color-comments :background ,bg-highlight :extend t))))
   `(org-block-end-line ((,class (:foreground ,color-comments :background ,bg-highlight :extend t))))
   `(org-table ((,class (:foreground ,fg-primary))))
   `(org-date ((,class (:foreground ,color-constants))))
   `(org-todo ((,class (:foreground ,ui-error :weight bold))))
   `(org-done ((,class (:foreground ,ui-success :weight bold))))

   ;; ============================================================
   ;; DIRED
   ;; ============================================================
   `(dired-directory ((,class (:foreground ,color-definitions :weight bold))))
   `(dired-header ((,class (:foreground ,color-definitions :weight bold))))
   `(dired-mark ((,class (:foreground ,ui-match))))
   `(dired-marked ((,class (:background ,bg-highlight :foreground ,ui-match))))

   ;; ============================================================
   ;; COMPLETION (Ivy/Vertico/etc)
   ;; ============================================================
   `(ivy-current-match ((,class (:background ,bg-highlight :weight bold))))
   `(ivy-minibuffer-match-face-1 ((,class (:foreground ,ui-match))))
   `(ivy-minibuffer-match-face-2 ((,class (:foreground ,ui-match :weight bold))))
   `(vertico-current ((,class (:background ,bg-highlight :weight bold))))

   ;; ============================================================
   ;; COMPANY COMPLETION
   ;; ============================================================
   `(company-preview ((,class (:background ,bg-highlight :foreground ,fg-dim))))
   `(company-preview-common ((,class (:background ,bg-highlight :foreground ,fg-primary))))
   `(company-tooltip ((,class (:background ,bg-secondary :foreground ,fg-primary))))
   `(company-tooltip-selection ((,class (:background ,bg-highlight))))
   `(company-tooltip-common ((,class (:foreground ,color-definitions :weight bold))))

   ;; ============================================================
   ;; LSP
   ;; ============================================================
   `(lsp-face-highlight-textual ((,class (:background ,bg-highlight))))
   `(lsp-face-highlight-read ((,class (:background ,bg-highlight))))
   `(lsp-face-highlight-write ((,class (:background ,bg-highlight :underline t))))

   ;; ============================================================
   ;; FLYCHECK/FLYMAKE
   ;; ============================================================
   `(flycheck-error ((,class (:underline (:style wave :color ,ui-error)))))
   `(flycheck-warning ((,class (:underline (:style wave :color ,ui-warning)))))
   `(flycheck-info ((,class (:underline (:style wave :color ,color-comments)))))
   `(flymake-error ((,class (:underline (:style wave :color ,ui-error)))))
   `(flymake-warning ((,class (:underline (:style wave :color ,ui-warning)))))
   `(flymake-note ((,class (:underline (:style wave :color ,color-comments)))))

   ;; ============================================================
   ;; GIT/MAGIT
   ;; ============================================================
   `(magit-branch-local ((,class (:foreground ,color-definitions :weight bold))))
   `(magit-branch-remote ((,class (:foreground ,color-constants :weight bold))))
   `(magit-hash ((,class (:foreground ,fg-dim))))
   `(magit-diff-added ((,class (:background ,bg-primary :foreground ,ui-success))))
   `(magit-diff-removed ((,class (:background ,bg-primary :foreground ,ui-error))))
   `(magit-diff-context ((,class (:background ,bg-primary :foreground ,fg-dim))))
   `(magit-section-heading ((,class (:foreground ,color-definitions :weight bold))))
   `(diff-added ((,class (:foreground ,ui-success))))
   `(diff-removed ((,class (:foreground ,ui-error))))

   ;; ============================================================
   ;; DOOM SPECIFIC
   ;; ============================================================
   `(doom-dashboard-banner ((,class (:foreground ,color-definitions))))
   `(doom-dashboard-footer ((,class (:foreground ,color-comments))))
   `(doom-dashboard-loaded ((,class (:foreground ,ui-success))))
   `(doom-dashboard-menu-desc ((,class (:foreground ,fg-primary))))
   `(doom-dashboard-menu-title ((,class (:foreground ,color-definitions :weight bold))))

   ;; ============================================================
   ;; MARKDOWN
   ;; ============================================================
   `(markdown-header-face-1 ((,class (:foreground ,color-definitions :weight bold :height 1.3))))
   `(markdown-header-face-2 ((,class (:foreground ,color-definitions :weight bold :height 1.2))))
   `(markdown-header-face-3 ((,class (:foreground ,color-definitions :weight bold :height 1.1))))
   `(markdown-code-face ((,class (:foreground ,color-constants :background ,bg-secondary))))
   `(markdown-inline-code-face ((,class (:foreground ,color-constants))))
   `(markdown-link-face ((,class (:foreground ,color-strings :underline t))))

   ;; ============================================================
   ;; NIX MODE
   ;; ============================================================
   `(nix-constant-face ((,class (:foreground ,color-numbers :weight bold))))
   `(nix-builtin-face ((,class (:foreground ,fg-primary))))
   `(nix-attribute-face ((,class (:foreground ,fg-primary))))

   ;; ============================================================
   ;; TERMINAL COLORS (for term/ansi-term/vterm)
   ;; ============================================================
   `(term-color-black ((,class (:background ,fg-primary :foreground ,fg-primary))))
   `(term-color-red ((,class (:background ,ui-error :foreground ,ui-error))))
   `(term-color-green ((,class (:background ,ui-success :foreground ,ui-success))))
   `(term-color-yellow ((,class (:background ,color-numbers :foreground ,color-numbers))))
   `(term-color-blue ((,class (:background ,color-comments :foreground ,color-comments))))
   `(term-color-magenta ((,class (:background ,color-constants :foreground ,color-constants))))
   `(term-color-cyan ((,class (:background ,color-strings :foreground ,color-strings))))
   `(term-color-white ((,class (:background ,bg-primary :foreground ,fg-primary))))))

;;;###autoload
(when load-file-name
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory (file-name-directory load-file-name))))

(provide-theme 'biscotty)

;;; biscotty-theme.el ends here
