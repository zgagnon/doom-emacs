;;; jellybeans-dark-theme.el --- Dark variant of the jellybeans color theme

;; Copyright (C) 2024

;; Author: Generated for Doom Emacs
;; Version: 1.0
;; Keywords: faces, themes

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; A dark variant of the jellybeans color theme, inspired by the original
;; jellybeans vim theme. Features a dark background with vibrant but muted
;; syntax highlighting colors that provide excellent readability and
;; visual harmony.

;;; Code:

(deftheme jellybeans-dark
  "Dark variant of the jellybeans color theme")

(let ((class '((class color) (min-colors 89)))
      ;; Background colors
      (bg-primary   "#151515")
      (bg-secondary "#1c1c1c") 
      (bg-alternate "#252525")
      (bg-region    "#404040")
      (bg-highlight "#2a2a2a")
      (bg-border    "#000000")
      
      ;; Foreground colors
      (fg-primary   "#e8e8d3")
      (fg-secondary "#d7d7d7")
      (fg-dim       "#999999")
      (fg-cursor    "#b0d0f0")
      
      ;; Line numbers
      (line-number      "#605958")
      (line-number-cur  "#ccc5c4")
      
      ;; Syntax highlighting
      (comment     "#888888")
      (string      "#99ad6a")
      (constant    "#cf6a4c")
      (function    "#fad07a")
      (keyword     "#8197bf")
      (type        "#ffb964")
      (identifier  "#c6b6ee")
      (special     "#799d6a")
      (structure   "#8fbfdc")
      (builtin     "#8fbfdc")
      (variable    "#cf6a4c")
      
      ;; UI colors
      (match       "#dd0093")
      (search      "#f0a0c0")
      (title       "#70b950")
      (warning     "#902020")
      (error       "#ea2828")
      (success     "#87dd32")
      
      ;; Mode line
      (modeline-bg "#dddddd")
      (modeline-fg "#000000")
      (modeline-inactive-bg "#333333")
      (modeline-inactive-fg "#888888")
      
      ;; Terminal colors (for reference)
      (term-black   "#393939")
      (term-red     "#ca674a")
      (term-green   "#96a967")
      (term-yellow  "#d3a94a")
      (term-blue    "#5778c1")
      (term-magenta "#9c35ac")
      (term-cyan    "#6eb5f3")
      (term-white   "#a9a9a9"))

  (custom-theme-set-faces
   'jellybeans-dark
   
   ;; Basic faces
   `(default ((,class (:background ,bg-primary :foreground ,fg-primary))))
   `(cursor ((,class (:background ,fg-cursor))))
   `(region ((,class (:background ,bg-region))))
   `(highlight ((,class (:background ,bg-highlight))))
   `(hl-line ((,class (:background ,bg-secondary))))
   `(fringe ((,class (:background ,bg-primary :foreground ,line-number))))
   `(border ((,class (:foreground ,bg-border))))
   `(vertical-border ((,class (:foreground ,bg-border))))
   
   ;; Font lock faces (syntax highlighting)
   `(font-lock-builtin-face ((,class (:foreground ,builtin))))
   `(font-lock-comment-face ((,class (:foreground ,comment :slant italic))))
   `(font-lock-constant-face ((,class (:foreground ,constant))))
   `(font-lock-function-name-face ((,class (:foreground ,function))))
   `(font-lock-keyword-face ((,class (:foreground ,keyword))))
   `(font-lock-string-face ((,class (:foreground ,string))))
   `(font-lock-type-face ((,class (:foreground ,type))))
   `(font-lock-variable-name-face ((,class (:foreground ,variable))))
   `(font-lock-warning-face ((,class (:foreground ,warning :weight bold))))
   `(font-lock-doc-face ((,class (:foreground ,comment :slant italic))))
   
   ;; Line numbers
   `(line-number ((,class (:foreground ,line-number :background ,bg-primary))))
   `(line-number-current-line ((,class (:foreground ,line-number-cur :background ,bg-secondary :weight bold))))
   
   ;; Search and match
   `(isearch ((,class (:background ,search :foreground ,bg-primary))))
   `(lazy-highlight ((,class (:background ,bg-highlight :foreground ,fg-primary))))
   `(match ((,class (:foreground ,match :weight bold))))
   `(show-paren-match ((,class (:foreground ,match :weight bold))))
   `(show-paren-mismatch ((,class (:background ,error :foreground ,fg-primary))))
   
   ;; Mode line
   `(mode-line ((,class (:background ,modeline-bg :foreground ,modeline-fg :box (:line-width 1 :color ,bg-border)))))
   `(mode-line-inactive ((,class (:background ,modeline-inactive-bg :foreground ,modeline-inactive-fg :box (:line-width 1 :color ,bg-border)))))
   
   ;; Org mode
   `(org-level-1 ((,class (:foreground ,title :weight bold :height 1.3))))
   `(org-level-2 ((,class (:foreground ,function :weight bold :height 1.2))))
   `(org-level-3 ((,class (:foreground ,keyword :weight bold :height 1.1))))
   `(org-level-4 ((,class (:foreground ,type :weight bold))))
   `(org-level-5 ((,class (:foreground ,identifier :weight bold))))
   `(org-level-6 ((,class (:foreground ,special :weight bold))))
   `(org-level-7 ((,class (:foreground ,structure :weight bold))))
   `(org-level-8 ((,class (:foreground ,string :weight bold))))
   `(org-code ((,class (:foreground ,constant))))
   `(org-block ((,class (:background ,bg-secondary :foreground ,fg-primary :extend t))))
   `(org-block-begin-line ((,class (:foreground ,comment :background ,bg-highlight :extend t))))
   `(org-block-end-line ((,class (:foreground ,comment :background ,bg-highlight :extend t))))
   `(org-table ((,class (:foreground ,structure))))
   `(org-date ((,class (:foreground ,special))))
   `(org-todo ((,class (:foreground ,error :weight bold))))
   `(org-done ((,class (:foreground ,success :weight bold))))
   
   ;; Dired
   `(dired-directory ((,class (:foreground ,keyword :weight bold))))
   `(dired-header ((,class (:foreground ,title :weight bold))))
   `(dired-mark ((,class (:foreground ,match))))
   `(dired-marked ((,class (:background ,bg-highlight :foreground ,match))))
   
   ;; Ivy/Helm/Selectrum completion
   `(ivy-current-match ((,class (:background ,bg-highlight :foreground ,fg-primary))))
   `(ivy-minibuffer-match-face-1 ((,class (:foreground ,function))))
   `(ivy-minibuffer-match-face-2 ((,class (:foreground ,keyword))))
   `(ivy-minibuffer-match-face-3 ((,class (:foreground ,type))))
   `(ivy-minibuffer-match-face-4 ((,class (:foreground ,identifier))))
   
   ;; Company completion
   `(company-preview ((,class (:background ,bg-highlight :foreground ,fg-dim))))
   `(company-preview-common ((,class (:background ,bg-highlight :foreground ,fg-primary))))
   `(company-tooltip ((,class (:background ,bg-secondary :foreground ,fg-primary))))
   `(company-tooltip-selection ((,class (:background ,bg-highlight))))
   `(company-tooltip-common ((,class (:foreground ,function :weight bold))))
   `(company-tooltip-common-selection ((,class (:foreground ,function :weight bold))))
   
   ;; LSP faces
   `(lsp-face-highlight-textual ((,class (:background ,bg-highlight))))
   `(lsp-face-highlight-read ((,class (:background ,bg-highlight))))
   `(lsp-face-highlight-write ((,class (:background ,bg-highlight))))
   
   ;; Flycheck
   `(flycheck-error ((,class (:underline (:style wave :color ,error)))))
   `(flycheck-warning ((,class (:underline (:style wave :color ,warning)))))
   `(flycheck-info ((,class (:underline (:style wave :color ,special)))))
   
   ;; Git/Magit
   `(magit-branch-local ((,class (:foreground ,keyword))))
   `(magit-branch-remote ((,class (:foreground ,type))))
   `(magit-hash ((,class (:foreground ,identifier))))
   `(magit-diff-added ((,class (:background ,bg-primary :foreground ,success))))
   `(magit-diff-removed ((,class (:background ,bg-primary :foreground ,error))))
   `(magit-diff-context ((,class (:background ,bg-primary :foreground ,fg-dim))))
   `(magit-section-heading ((,class (:foreground ,title :weight bold))))
   
   ;; Doom specific
   `(doom-dashboard-banner ((,class (:foreground ,title))))
   `(doom-dashboard-footer ((,class (:foreground ,comment))))
   `(doom-dashboard-footer-icon ((,class (:foreground ,keyword))))
   `(doom-dashboard-loaded ((,class (:foreground ,success))))
   `(doom-dashboard-menu-desc ((,class (:foreground ,fg-primary))))
   `(doom-dashboard-menu-title ((,class (:foreground ,function))))
   
   ;; Terminal colors
   `(term-color-black ((,class (:background ,term-black :foreground ,term-black))))
   `(term-color-red ((,class (:background ,term-red :foreground ,term-red))))
   `(term-color-green ((,class (:background ,term-green :foreground ,term-green))))
   `(term-color-yellow ((,class (:background ,term-yellow :foreground ,term-yellow))))
   `(term-color-blue ((,class (:background ,term-blue :foreground ,term-blue))))
   `(term-color-magenta ((,class (:background ,term-magenta :foreground ,term-magenta))))
   `(term-color-cyan ((,class (:background ,term-cyan :foreground ,term-cyan))))
   `(term-color-white ((,class (:background ,term-white :foreground ,term-white))))))

;;;###autoload
(when load-file-name
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory (file-name-directory load-file-name))))

(provide-theme 'jellybeans-dark)

;;; jellybeans-dark-theme.el ends here