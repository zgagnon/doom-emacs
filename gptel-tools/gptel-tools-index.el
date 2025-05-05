;;; gptel-tools-index.el --- Index file for gptel tools -*- lexical-binding: t; -*-

;;; Commentary:
;; This file loads and provides all the gptel-tools modules

;;; Code:
(require 'gptel)
(require 'buffer-tools)
;; (require 'file-tools)
;; (require 'web-tools)
(require 'search-tools)
(require 'project-tools)
(require 'elisp-tools)

;; Mode-specific tools
(require 'mode-specific-tools)
(require 'org-mode-tools)
(require 'programming-tools)

;; Documentation tools
(require 'adr-tools)

(provide 'gptel-tools-index)
;;; gptel-tools-index.el ends here
