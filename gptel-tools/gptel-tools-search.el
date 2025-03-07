;;; gptel-tools-search.el --- Search tools for gptel -*- lexical-binding: t; -*-

;;; Commentary:
;; Provides tools for searching through files and directories

;;; Code:
(require 'gptel)

;; Ripgrep search and context tool
(gptel-make-tool
 :name "search_and_context"
 :function (lambda (pattern dir &optional file-pattern)
             (let* ((default-directory (expand-file-name dir))
                    (file-arg (if file-pattern (concat "--glob=" file-pattern) ""))
                    (cmd (format "rg --color never --line-number --no-heading %s %s"
                                 file-arg (shell-quote-argument pattern)))
                    (results (shell-command-to-string cmd))
                    (matches (split-string results "\n" t))
                    (files-opened '())
                    (context-added '()))
               
               ;; Display the search results in a buffer for reference
               (with-current-buffer (get-buffer-create "*ripgrep-results*")
                 (erase-buffer)
                 (insert (format "Search results for pattern: %s\nin directory: %s\n\n" 
                                pattern (expand-file-name dir)))
                 (insert results)
                 (display-buffer (current-buffer)))
               
               ;; Parse results and open files
               (dolist (match matches)
                 (when (string-match "^\\([^:]+\\):\\([0-9]+\\):" match)
                   (let* ((file (match-string 1 match))
                          (line (string-to-number (match-string 2 match)))
                          (abs-path (expand-file-name file default-directory)))
                     
                     ;; Only open each file once
                     (unless (member file files-opened)
                       (push file files-opened)
                       
                       ;; Open the file in a buffer
                       (with-current-buffer (find-file-noselect abs-path)
                         ;; Go to the line of the first match in this file
                         (goto-char (point-min))
                         (forward-line (1- line))
                         
                         ;; Add file to gptel context
                         (gptel-add (current-buffer))
                         (push file context-added))))))
               
               ;; Return summary of what was done
               (format "Searched for '%s' in %s.\nFound matches in %d files.\nOpened and added to context: %s"
                       pattern
                       (expand-file-name dir)
                       (length files-opened)
                       (mapconcat 'identity context-added ", "))))
 :description "Search files with ripgrep, open matching files, and add them to gptel context"
 :args (list '(:name "pattern"
               :type string
               :description "The search pattern to find in files")
             '(:name "dir"
               :type string
               :description "The directory to search in (default: project root)")
             '(:name "file-pattern"
               :type string
               :description "Optional file pattern to limit search (e.g., '*.el' or '*.org')"
               :optional t))
 :category "search")

(provide 'gptel-tools-search)
;;; gptel-tools-search.el ends here
