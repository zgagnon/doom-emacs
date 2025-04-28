;;; buffer-tools.el --- Buffer management tools for gptel -*- lexical-binding: t; -*-

;; Copyright (C) 2023-2024 Zell Liew

;; Author: Zell Liew
;; Keywords: gptel, tools, buffers
;; Version: 1.0

;;; Commentary:
;; This package provides buffer management tools for gptel,
;; allowing the LLM to list, switch between, and manipulate Emacs buffers,
;; as well as open files in buffers and save buffers.

;;; Code:
(require 'gptel)

(defun gptel-list-buffers ()
  "List all available buffers with their names and major modes.
Returns a list of buffer information in a structured format."
  (let ((buffer-list '())
        (current-buffer (buffer-name)))
    (dolist (buf (buffer-list))
      (let* ((buf-name (buffer-name buf))
             (mode (with-current-buffer buf major-mode))
             (modified (buffer-modified-p buf))
             (file (or (buffer-file-name buf) "")))
        (push (format "%s%s [%s] %s"
                      (if (string= buf-name current-buffer) "* " "  ")
                      buf-name
                      mode
                      (if (string= file "") "" (concat "(" file ")")))
              buffer-list)))
    (setq buffer-list (nreverse buffer-list))
    (mapconcat #'identity buffer-list "\n")))

(gptel-make-tool
 :function #'gptel-list-buffers
 :name "list_buffers"
 :description "List all available buffers with their names and major modes"
 :args nil
 :category "buffer-management")

(defun gptel-switch-to-buffer (buffer-name)
  "Switch to the buffer named BUFFER-NAME.
If the buffer doesn't exist, return an error message."
  (if (get-buffer buffer-name)
      (progn
        (switch-to-buffer buffer-name)
        (format "Switched to buffer: %s" buffer-name))
    (format "Error: No buffer named '%s' exists" buffer-name)))

(gptel-make-tool
 :function #'gptel-switch-to-buffer
 :name "switch_to_buffer"
 :description "Switch to a buffer with the given name"
 :args (list '(:name "buffer_name"
               :type string
               :description "The name of the buffer to switch to"))
 :category "buffer-management")

(defun gptel-open-file (file-path)
  "Open a file at FILE-PATH in a buffer.
If the file doesn't exist, it will be created when saved."
  (condition-case err
      (progn
        (find-file file-path)
        (format "Opened file: %s in buffer %s" file-path (buffer-name)))
    (error (format "Error opening file: %s" (error-message-string err)))))

(gptel-make-tool
 :function #'gptel-open-file
 :name "open_file"
 :description "Open a file in a buffer. If the file doesn't exist, it will be created when saved"
 :args (list '(:name "file_path"
               :type string
               :description "The path to the file to open"))
 :category "buffer-management")

(defun gptel-save-buffer (buffer-name)
  "Save the buffer named BUFFER-NAME if it exists and is modified.
If no BUFFER-NAME is provided, save the current buffer."
  (let ((buf (if (string= buffer-name "")
                 (current-buffer)
               (get-buffer buffer-name))))
    (if (not buf)
        (format "Error: No buffer named '%s' exists" buffer-name)
      (with-current-buffer buf
        (if (not (buffer-modified-p))
            (format "Buffer '%s' is not modified, no need to save" (buffer-name buf))
          (if (not (buffer-file-name buf))
              "Cannot save: buffer is not associated with a file"
            (save-buffer)
            (format "Saved buffer '%s' to %s" (buffer-name buf) (buffer-file-name buf))))))))

(gptel-make-tool
 :function #'gptel-save-buffer
 :name "save_buffer"
 :description "Save a specific buffer to its file"
 :args (list '(:name "buffer_name"
               :type string
               :description "The name of the buffer to save (empty string for current buffer)"))
 :category "buffer-management")

(defun gptel-get-buffer-content (buffer-name)
  "Get the content of the buffer named BUFFER-NAME.
If the buffer doesn't exist, return an error message."
  (let ((buf (get-buffer buffer-name)))
    (if (not buf)
        (format "Error: No buffer named '%s' exists" buffer-name)
      (with-current-buffer buf
        (buffer-substring-no-properties (point-min) (point-min))))))

(gptel-make-tool
 :function #'gptel-get-buffer-content
 :name "get_buffer_content"
 :description "Get the content of a buffer"
 :args (list '(:name "buffer_name"
               :type string
               :description "The name of the buffer to get content from"))
 :category "buffer-management")

(defun gptel-kill-buffer (buffer-name)
  "Kill (close) the buffer named BUFFER-NAME.
If the buffer doesn't exist, return an error message."
  (let ((buf (get-buffer buffer-name)))
    (if (not buf)
        (format "Error: No buffer named '%s' exists" buffer-name)
      (if (kill-buffer buf)
          (format "Killed buffer: %s" buffer-name)
        (format "Failed to kill buffer: %s" buffer-name)))))

(gptel-make-tool
 :function #'gptel-kill-buffer
 :name "kill_buffer"
 :description "Kill (close) a buffer with the given name"
 :args (list '(:name "buffer_name"
               :type string
               :description "The name of the buffer to kill"))
 :category "buffer-management")

(defun gptel-rename-buffer (buffer-name new-name)
  "Rename the buffer BUFFER-NAME to NEW-NAME.
If the buffer doesn't exist, return an error message."
  (let ((buf (get-buffer buffer-name)))
    (if (not buf)
        (format "Error: No buffer named '%s' exists" buffer-name)
      (with-current-buffer buf
        (rename-buffer new-name)
        (format "Renamed buffer from '%s' to '%s'" buffer-name new-name)))))

(gptel-make-tool
 :function #'gptel-rename-buffer
 :name "rename_buffer"
 :description "Rename a buffer"
 :args (list '(:name "buffer_name"
               :type string
               :description "The current name of the buffer")
             '(:name "new_name"
               :type string
               :description "The new name for the buffer"))
 :category "buffer-management")

(defun gptel-set-buffer-content (buffer-name content)
  "Replace the entire content of BUFFER-NAME with CONTENT.
If the buffer doesn't exist, return an error message."
  (let ((buf (get-buffer buffer-name)))
    (if (not buf)
        (format "Error: No buffer named '%s' exists" buffer-name)
      (with-current-buffer buf
        (let ((buffer-read-only nil))
          (erase-buffer)
          (insert content)
          (format "Content of buffer '%s' has been replaced" buffer-name))))))

(gptel-make-tool
 :function #'gptel-set-buffer-content
 :name "set_buffer_content"
 :description "Replace the entire content of a buffer"
 :args (list '(:name "buffer_name"
               :type string
               :description "The name of the buffer to modify")
             '(:name "content"
               :type string
               :description "The new content to put in the buffer"))
 :category "buffer-management")

(defun gptel-insert-into-buffer (buffer-name content position)
  "Insert CONTENT into buffer BUFFER-NAME at POSITION.
POSITION can be 'beginning', 'end', 'point', or a line number."
  (let ((buf (get-buffer buffer-name)))
    (if (not buf)
        (format "Error: No buffer named '%s' exists" buffer-name)
      (with-current-buffer buf
        (let ((buffer-read-only nil)
              (pos (cond
                    ((string= position "beginning") (point-min))
                    ((string= position "end") (point-max))
                    ((string= position "point") (point))
                    ((string-match "^[0-9]+$" position)
                     (save-excursion
                       (goto-char (point-min))
                       (forward-line (1- (string-to-number position)))
                       (point)))
                    (t (point)))))
          (goto-char pos)
          (insert content)
          (format "Inserted content into buffer '%s' at %s"
                  buffer-name
                  (cond
                   ((string= position "beginning") "the beginning")
                   ((string= position "end") "the end")
                   ((string= position "point") "the current point")
                   ((string-match "^[0-9]+$" position) (format "line %s" position))
                   (t "the current position"))))))))

(gptel-make-tool
 :function #'gptel-insert-into-buffer
 :name "insert_into_buffer"
 :description "Insert content into a buffer at a specified position"
 :args (list '(:name "buffer_name"
               :type string
               :description "The name of the buffer to insert into")
             '(:name "content"
               :type string
               :description "The content to insert")
             '(:name "position"
               :type string
               :description "Where to insert: 'beginning', 'end', 'point', or a line number"))
 :category "buffer-management")

(defun gptel-create-new-buffer (buffer-name &optional major-mode-name)
  "Create a new buffer named BUFFER-NAME.
Optionally set it to MAJOR-MODE-NAME if provided and valid."
  (let ((new-buffer (generate-new-buffer buffer-name)))
    (with-current-buffer new-buffer
      (when (and major-mode-name
                 (not (string= major-mode-name "")))
        (let ((mode-function (intern-soft (if (string-suffix-p "-mode" major-mode-name)
                                             major-mode-name
                                           (concat major-mode-name "-mode")))))
          (if (and mode-function (fboundp mode-function))
              (funcall mode-function)
            (message "Warning: Could not set major mode '%s'" major-mode-name))))
      (switch-to-buffer new-buffer)
      (format "Created new buffer: %s%s"
              buffer-name
              (if (and major-mode-name (not (string= major-mode-name "")))
                  (format " with mode %s" major-mode)
                "")))))

(gptel-make-tool
 :function #'gptel-create-new-buffer
 :name "create_new_buffer"
 :description "Create a new buffer with an optional major mode"
 :args (list '(:name "buffer_name"
               :type string
               :description "The name for the new buffer")
             '(:name "major_mode_name"
               :type string
               :description "Optional major mode to set for the buffer"))
 :category "buffer-management")

(defun gptel-get-buffer-info (buffer-name)
  "Get detailed information about the buffer named BUFFER-NAME."
  (let ((buf (if (string= buffer-name "")
                 (current-buffer)
               (get-buffer buffer-name))))
    (if (not buf)
        (format "Error: No buffer named '%s' exists" buffer-name)
      (with-current-buffer buf
        (let ((file-name (buffer-file-name))
              (modified (buffer-modified-p))
              (read-only buffer-read-only)
              (size (buffer-size))
              (mode major-mode)
              (encoding buffer-file-coding-system)
              (position (point))
              (line (line-number-at-pos))
              (column (current-column)))
          (format "Buffer: %s
File: %s
Modified: %s
Read-only: %s
Size: %d characters
Major mode: %s
Encoding: %s
Point position: %d
Line: %d
Column: %d"
                  (buffer-name)
                  (or file-name "Not visiting a file")
                  (if modified "Yes" "No")
                  (if read-only "Yes" "No")
                  size
                  mode
                  encoding
                  position
                  line
                  column))))))

(gptel-make-tool
 :function #'gptel-get-buffer-info
 :name "get_buffer_info"
 :description "Get detailed information about a buffer"
 :args (list '(:name "buffer_name"
               :type string
               :description "The name of the buffer (empty string for current buffer)"))
 :category "buffer-management")

(provide 'buffer-tools)
;;; buffer-tools.el ends here