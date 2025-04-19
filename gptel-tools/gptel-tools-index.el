;;; gptel-tools-index.el --- Index file for gptel tools -*- lexical-binding: t; -*-

;;; Commentary:
;; This file loads and provides all the gptel-tools modules

;;; Code:
(require 'gptel)
;; (require 'buffer-tools)
;; (require 'file-tools)
(require 'web-tools)
(require 'search-tools)
(require 'project-tools)

(defun gptel-tool-langchain-run (chain-name input)
  "Run a defined langchain CHAIN-NAME with INPUT."
  (gptel-langchain-run-chain chain-name input))

;; Open file tool interface
(defun gptel-tool-open-file (filepath)
  "Open FILEPATH in a buffer and return its buffer name."
  (gptel-open-file filepath))
(provide 'gptel-tools-index)
;;; gptel-tools-index.el ends here
