;;; programming-tools.el --- Programming language support tools for gptel -*- lexical-binding: t; -*-

;;; Commentary:
;; Provides tools for working with programming languages, including
;; code completion, syntax checking, LSP integration, and REPL interaction.

;;; Code:
(require 'gptel)

(defun gptel-get-syntax-errors (buffer-name)
  "Get syntax errors for BUFFER-NAME using flycheck or flymake if available.
If BUFFER-NAME is empty, use the current gptel buffer."
  (let ((buffer (if (string-empty-p buffer-name)
                   (gptel-get-buffer)
                 (get-buffer buffer-name))))
    (if (not buffer)
        (format "Buffer \"%s\" not found" buffer-name)
      (with-current-buffer buffer
        (cond
         ;; Check flycheck first
         ((and (boundp 'flycheck-mode) flycheck-mode)
          (let ((errors '()))
            (dolist (err (flycheck-overlay-errors-in (point-min) (point-max)))
              (push (format "Line %d: %s [%s]"
                           (flycheck-error-line err)
                           (flycheck-error-message err)
                           (flycheck-error-level err))
                   errors))
            (if errors
                (mapconcat #'identity (nreverse errors) "\n")
              "No syntax errors found with flycheck")))
         
         ;; Then check flymake
         ((and (boundp 'flymake-mode) flymake-mode)
          (if (fboundp 'flymake-diagnostics)
              (let ((errors '()))
                (dolist (diag (flymake-diagnostics))
                  (push (format "Line %d: %s [%s]"
                               (flymake--diag-beg diag)
                               (flymake--diag-text diag)
                               (flymake--diag-type diag))
                       errors))
                (if errors
                    (mapconcat #'identity (nreverse errors) "\n")
                  "No syntax errors found with flymake"))
            "Flymake is enabled but flymake-diagnostics function not available"))
         
         ;; No syntax checker available
         (t "No syntax checker (flycheck/flymake) is active in this buffer"))))))

(defun gptel-send-to-repl (code)
  "Send CODE to the appropriate REPL for the current buffer's mode.
Works with various REPLs like ielm, cider, slime, python, etc."
  (let ((buffer (gptel-get-buffer)))
    (if (not buffer)
        "No active gptel buffer found"
      (with-current-buffer buffer
        (let ((major-mode-name (symbol-name major-mode)))
          (condition-case err
              (cond
               ;; Emacs Lisp
               ((string-match "emacs-lisp" major-mode-name)
                (unless (get-buffer "*ielm*")
                  (ielm))
                (let ((ielm-buffer (get-buffer "*ielm*")))
                  (when ielm-buffer
                    (with-current-buffer ielm-buffer
                      (goto-char (point-max))
                      (insert code)
                      (ielm-send-input)
                      (let ((result (buffer-substring-no-properties 
                                     (save-excursion
                                       (forward-line -1)
                                       (line-beginning-position))
                                     (save-excursion
                                       (forward-line -1)
                                       (line-end-position)))))
                        (format "Sent to ielm. Result: %s" result))))))
               
               ;; Clojure (CIDER)
               ((and (string-match "clojure" major-mode-name)
                     (fboundp 'cider-current-repl))
                (if (cider-current-repl)
                    (progn
                      (with-current-buffer (cider-current-repl)
                        (goto-char (point-max))
                        (insert code)
                        (cider-repl-return))
                      "Code sent to CIDER REPL")
                  "No active CIDER REPL found. Start one with M-x cider-jack-in"))
               
               ;; Common Lisp (SLIME)
               ((and (string-match "lisp" major-mode-name)
                     (fboundp 'slime-repl))
                (if (get-buffer "*slime-repl*")
                    (progn
                      (with-current-buffer "*slime-repl*"
                        (goto-char (point-max))
                        (insert code)
                        (slime-repl-return))
                      "Code sent to SLIME REPL")
                  "No active SLIME REPL found. Start one with M-x slime"))
               
               ;; Python
               ((string-match "python" major-mode-name)
                (cond
                 ((fboundp 'python-shell-send-string)
                  (python-shell-send-string code)
                  "Code sent to Python REPL")
                 ((fboundp 'py-shell-send-string)
                  (py-shell-send-string code)
                  "Code sent to Python REPL (using python-mode.el)")
                 (t "No Python REPL interface found")))
               
               ;; Ruby
               ((and (string-match "ruby" major-mode-name)
                     (fboundp 'inf-ruby-console-auto))
                (unless (get-buffer "*ruby*")
                  (inf-ruby-console-auto))
                (ruby-send-region (point) (save-excursion
                                            (insert code)
                                            (point)))
                (delete-region (point) (- (point) (length code)))
                "Code sent to Ruby REPL")
               
               ;; JavaScript/TypeScript
               ((and (or (string-match "js" major-mode-name)
                         (string-match "typescript" major-mode-name))
                     (fboundp 'nodejs-repl))
                (unless (get-buffer "*nodejs*")
                  (nodejs-repl))
                (nodejs-repl-send-string code)
                "Code sent to Node.js REPL")
               
               ;; Scala
               ((and (string-match "scala" major-mode-name)
                     (fboundp 'sbt-send-region))
                (sbt-send-region (point) (save-excursion
                                           (insert code)
                                           (point)))
                (delete-region (point) (- (point) (length code)))
                "Code sent to sbt console")
               
               ;; Fallback for unknown modes
               (t (format "No known REPL for %s mode" major-mode-name)))
            (error (format "Error sending to REPL: %S" err))))))))

(defun gptel-get-lsp-info (buffer-name)
  "Get LSP information for BUFFER-NAME if LSP is active.
If BUFFER-NAME is empty, use the current gptel buffer."
  (let ((buffer (if (string-empty-p buffer-name)
                   (gptel-get-buffer)
                 (get-buffer buffer-name))))
    (if (not buffer)
        (format "Buffer \"%s\" not found" buffer-name)
      (with-current-buffer buffer
        (cond
         ;; Check for lsp-mode
         ((and (fboundp 'lsp-workspaces) (lsp-workspaces))
          (let* ((workspaces (lsp-workspaces))
                 (workspace-info (mapconcat 
                                  (lambda (ws)
                                    (format "Server: %s, Status: %s"
                                            (lsp--workspace-print ws)
                                            (lsp--workspace-status ws)))
                                  workspaces "\n"))
                 (capabilities (condition-case nil
                                  (mapconcat 
                                   (lambda (cap)
                                     (format "- %s" cap))
                                   (mapcar #'car (lsp-session-server-capabilities))
                                   "\n")
                                (error "Could not retrieve capabilities"))))
            (format "LSP Information:\n%s\n\nCapabilities:\n%s" 
                    workspace-info
                    capabilities)))
         
         ;; Check for eglot
         ((and (fboundp 'eglot-current-server) (eglot-current-server))
          (let* ((server (eglot-current-server))
                 (server-info (format "Server: %s" (eglot--server-info server)))
                 (capabilities (condition-case nil
                                  (format "Project: %s" 
                                          (eglot--project-nickname (eglot--project server)))
                                (error "Could not retrieve capabilities"))))
            (format "Eglot Information:\n%s\n%s" 
                    server-info 
                    capabilities)))
         
         ;; No LSP
         (t "No Language Server Protocol (LSP) active in this buffer"))))))

;; Register the tools

(gptel-make-tool
 :function #'gptel-get-syntax-errors
 :name "get_syntax_errors"
 :description "Get syntax errors for a buffer using flycheck or flymake"
 :args (list '(:name "buffer_name"
               :type string
               :description "The name of the buffer (empty string for current buffer)"))
 :category "programming")

(gptel-make-tool
 :function #'gptel-send-to-repl
 :name "send_to_repl"
 :description "Send code to the appropriate REPL for the current buffer's mode"
 :args (list '(:name "code"
               :type string
               :description "The code to send to the REPL"))
 :category "programming")

(gptel-make-tool
 :function #'gptel-get-lsp-info
 :name "get_lsp_info"
 :description "Get Language Server Protocol information for a buffer if LSP is active"
 :args (list '(:name "buffer_name"
               :type string
               :description "The name of the buffer (empty string for current buffer)"))
 :category "programming")

(provide 'programming-tools)
;;; programming-tools.el ends here