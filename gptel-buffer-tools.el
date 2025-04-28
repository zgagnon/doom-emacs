;;; gptel-buffer-tools.el --- Buffer management tools for gptel -*- lexical-binding: t; -*-

;;; Commentary:
;; This package provides tools for managing Emacs buffers through gptel.
;; It allows listing, switching between, and manipulating buffers.

;;; Code:

(require 'gptel)

;;;###autoload
(defun gptel-list-buffers ()
  "List all buffers and return formatted information about them."
  (let ((buffer-info '()))
    (dolist (buffer (buffer-list))
      (let* ((name (buffer-name buffer))
             (file (or (buffer-file-name buffer) ""))
             (mode (with-current-buffer buffer major-mode))
             (modified (if (buffer-modified-p buffer) "*" ""))
             (size (buffer-size buffer))
             (info (format "[%s] %s%s (%s) - %d bytes"
                           mode name modified file size)))
        (push info buffer-info)))
    (mapconcat #'identity (nreverse buffer-info) "\n")))

;;;###autoload
(defun gptel-switch-to-buffer (buffer-name)
  "Switch to buffer with BUFFER-NAME."
  (if (get-buffer buffer-name)
      (progn
        (switch-to-buffer buffer-name)
        (format "Switched to buffer: %s" buffer-name))
    (format "Buffer not found: %s" buffer-name)))

;;;###autoload
(defun gptel-kill-buffer (buffer-name)
  "Kill buffer with BUFFER-NAME."
  (if (get-buffer buffer-name)
      (progn
        (kill-buffer buffer-name)
        (format "Killed buffer: %s" buffer-name))
    (format "Buffer not found: %s" buffer-name)))

;;;###autoload
(defun gptel-get-buffer-content (buffer-name)
  "Get content of buffer with BUFFER-NAME."
  (if (get-buffer buffer-name)
      (with-current-buffer buffer-name
        (buffer-string))
    (format "Buffer not found: %s" buffer-name)))

;;;###autoload
(defun gptel-create-buffer (buffer-name)
  "Create a new buffer with BUFFER-NAME."
  (let ((buffer (get-buffer-create buffer-name)))
    (with-current-buffer buffer
      (switch-to-buffer buffer)
      (format "Created and switched to buffer: %s" buffer-name))))

;;;###autoload
(defun gptel-rename-buffer (old-name new-name)
  "Rename buffer from OLD-NAME to NEW-NAME."
  (if (get-buffer old-name)
      (with-current-buffer old-name
        (rename-buffer new-name)
        (format "Renamed buffer from '%s' to '%s'" old-name new-name))
    (format "Buffer not found: %s" old-name)))

;;;###autoload
(defun gptel-get-visible-buffers ()
  "Return a list of currently visible buffers."
  (let ((visible-buffers '()))
    (dolist (frame (frame-list))
      (dolist (window (window-list frame))
        (let* ((buffer (window-buffer window))
               (name (buffer-name buffer)))
          (push name visible-buffers))))
    (mapconcat #'identity (delete-dups (nreverse visible-buffers)) "\n")))

;;;###autoload
(defun gptel-get-buffer-mode (buffer-name)
  "Get major mode of buffer with BUFFER-NAME."
  (if (get-buffer buffer-name)
      (with-current-buffer buffer-name
        (format "%s" major-mode))
    (format "Buffer not found: %s" buffer-name)))

;; Register the functions with gptel
(gptel-make-function "list_buffers"
                     #'gptel-list-buffers
                     "List all Emacs buffers with their details"
                     nil)

(gptel-make-function "switch_to_buffer"
                     #'gptel-switch-to-buffer
                     "Switch to a specific buffer by name"
                     '((:name "buffer_name" :type "string" :description "Name of the buffer to switch to")))

(gptel-make-function "kill_buffer"
                     #'gptel-kill-buffer
                     "Kill (close) a specific buffer by name"
                     '((:name "buffer_name" :type "string" :description "Name of the buffer to kill")))

(gptel-make-function "get_buffer_content"
                     #'gptel-get-buffer-content
                     "Get the content of a specific buffer"
                     '((:name "buffer_name" :type "string" :description "Name of the buffer to get content from")))

(gptel-make-function "create_buffer"
                     #'gptel-create-buffer
                     "Create a new buffer with a given name"
                     '((:name "buffer_name" :type "string" :description "Name for the new buffer")))

(gptel-make-function "rename_buffer"
                     #'gptel-rename-buffer
                     "Rename an existing buffer"
                     '((:name "old_name" :type "string" :description "Current name of the buffer")
                       (:name "new_name" :type "string" :description "New name for the buffer")))

(gptel-make-function "get_visible_buffers"
                     #'gptel-get-visible-buffers
                     "Get list of currently visible buffers across all frames and windows"
                     nil)

(gptel-make-function "get_buffer_mode"
                     #'gptel-get-buffer-mode
                     "Get the major mode of a specific buffer"
                     '((:name "buffer_name" :type "string" :description "Name of the buffer to check")))

(provide 'gptel-buffer-tools)
;;; gptel-buffer-tools.el ends here