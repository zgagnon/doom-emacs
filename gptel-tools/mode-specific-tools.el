;;; mode-specific-tools.el --- Mode-specific operations for gptel -*- lexical-binding: t; -*-

;;; Commentary:
;; Provides tools for detecting and working with specific major/minor modes in Emacs

;;; Code:
(require 'gptel)

(defun gptel-get-buffer-mode-info (buffer-name)
  "Get detailed information about the major and minor modes in BUFFER-NAME.
If BUFFER-NAME is empty, use the current gptel buffer."
  (let ((buffer (if (string-empty-p buffer-name)
                    (gptel-get-buffer)
                  (get-buffer buffer-name))))
    (if (not buffer)
        (format "Buffer \"%s\" not found" buffer-name)
      (with-current-buffer buffer
        (let ((major-mode-info (format "Major mode: %s" major-mode))
              (minor-modes-list (mapcar #'symbol-name
                                        (seq-filter (lambda (mode)
                                                      (and (boundp mode)
                                                           (symbol-value mode)
                                                           (string-suffix-p "-mode" (symbol-name mode))
                                                           (not (eq mode major-mode))))
                                                    minor-mode-list)))
              (indentation-info (format "Indentation: tab-width=%s, indent-tabs-mode=%s"
                                        tab-width indent-tabs-mode))
              (syntax-table-info (format "Syntax table: %S" (syntax-table)))
              (local-map-info (if (current-local-map)
                                  (format "Local keymap: %S" (current-local-map))
                                "No local keymap")))
          (format "%s\nMinor modes: %s\n%s\n%s"
                  major-mode-info
                  (if minor-modes-list
                      (mapconcat #'identity minor-modes-list ", ")
                    "None")
                  indentation-info
                  local-map-info))))))

(defun gptel-get-mode-documentation (mode-name)
  "Get documentation for a mode with MODE-NAME.
MODE-NAME should be a string representing a mode (with or without -mode suffix)."
  (let* ((mode-symbol (intern 
                       (if (string-suffix-p "-mode" mode-name)
                           mode-name
                         (concat mode-name "-mode"))))
         (doc nil))
    (condition-case err
        (if (fboundp mode-symbol)
            (setq doc (documentation mode-symbol))
          (format "Mode %s is not a defined function" mode-name))
      (error (format "Error retrieving documentation: %S" err)))
    (or doc (format "No documentation found for %s" mode-name))))

(defun gptel-execute-mode-specific-command (command)
  "Execute mode-specific COMMAND in the current gptel buffer.
This is useful for running commands that are relevant to the current major mode."
  (let ((buffer (gptel-get-buffer)))
    (if (not buffer)
        "No active gptel buffer found"
      (condition-case err
          (with-current-buffer buffer
            (let ((cmd-symbol (intern command)))
              (if (commandp cmd-symbol)
                  (progn
                    (call-interactively cmd-symbol)
                    (format "Command %s executed successfully" command))
                (format "%s is not a valid command" command))))
        (error (format "Error executing command: %S" err))))))

;; Register the tools

(gptel-make-tool
 :function #'gptel-get-buffer-mode-info
 :name "get_buffer_mode_info"
 :description "Get detailed information about the major and minor modes in a buffer"
 :args (list '(:name "buffer_name"
               :type string
               :description "The name of the buffer (empty string for current buffer)"))
 :category "emacs-modes")

(gptel-make-tool
 :function #'gptel-get-mode-documentation
 :name "get_mode_documentation"
 :description "Get documentation for a specific major or minor mode"
 :args (list '(:name "mode_name"
               :type string
               :description "The name of the mode (with or without -mode suffix)"))
 :category "emacs-modes")

(gptel-make-tool
 :function #'gptel-execute-mode-specific-command
 :name "execute_mode_command"
 :description "Execute a mode-specific command in the current buffer"
 :args (list '(:name "command"
               :type string
               :description "The command name to execute (should be relevant to current mode)"))
 :category "emacs-modes")

(provide 'mode-specific-tools)
;;; mode-specific-tools.el ends here