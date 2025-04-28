;;; org-mode-tools.el --- Org-mode specific tools for gptel -*- lexical-binding: t; -*-

;;; Commentary:
;; Provides specialized tools for working with org-mode files,
;; including task management, agenda views, etc.

;;; Code:
(require 'gptel)
(require 'org)

(defun gptel-org-get-structure (buffer-name)
  "Get the heading structure of an org file in BUFFER-NAME.
If BUFFER-NAME is empty, use the current gptel buffer."
  (let ((buffer (if (string-empty-p buffer-name)
                   (gptel-get-buffer)
                 (get-buffer buffer-name))))
    (if (not buffer)
        (format "Buffer \"%s\" not found" buffer-name)
      (with-current-buffer buffer
        (if (not (derived-mode-p 'org-mode))
            "Buffer is not in org-mode"
          (let ((structure ""))
            (org-map-entries
             (lambda ()
               (let* ((level (org-current-level))
                      (heading (org-get-heading t t t t))
                      (indent (make-string (* 2 (- level 1)) ?\s)))
                 (setq structure (concat structure indent "* " heading "\n"))))
             t 'file)
            (if (string-empty-p structure)
                "No headings found in the org file"
              structure)))))))

(defun gptel-org-get-todos (buffer-name)
  "Get all TODO items from an org file in BUFFER-NAME.
If BUFFER-NAME is empty, use the current gptel buffer."
  (let ((buffer (if (string-empty-p buffer-name)
                   (gptel-get-buffer)
                 (get-buffer buffer-name))))
    (if (not buffer)
        (format "Buffer \"%s\" not found" buffer-name)
      (with-current-buffer buffer
        (if (not (derived-mode-p 'org-mode))
            "Buffer is not in org-mode"
          (let ((todos ""))
            (org-map-entries
             (lambda ()
               (let* ((level (org-current-level))
                      (heading (org-get-heading t t t t))
                      (todo-state (org-get-todo-state))
                      (priority (org-get-priority (org-get-heading t t)))
                      (tags (org-get-tags))
                      (indent (make-string (* 2 (- level 1)) ?\s)))
                 (when todo-state
                   (setq todos (concat todos
                                      indent "* " todo-state " " heading
                                      (if tags (format " :%s:" (mapconcat #'identity tags ":")) "")
                                      (if (/= priority org-default-priority)
                                          (format " [#%c]" priority) "")
                                      "\n")))))
             t 'file)
            (if (string-empty-p todos)
                "No TODO items found in the org file"
              todos)))))))

(defun gptel-org-create-heading (heading level todo-state tags priority)
  "Create a new org heading in the current gptel buffer.
HEADING is the text of the heading.
LEVEL is the heading level (1-9).
TODO-STATE is the optional TODO state (can be empty).
TAGS is a comma-separated list of tags (can be empty).
PRIORITY is the priority (A, B, C or empty for default)."
  (let ((buffer (gptel-get-buffer)))
    (if (not buffer)
        "No active gptel buffer found"
      (with-current-buffer buffer
        (if (not (derived-mode-p 'org-mode))
            "Buffer is not in org-mode"
          (condition-case err
              (save-excursion
                (goto-char (point-max))
                (unless (bolp) (insert "\n"))
                
                ;; Insert the heading with appropriate level
                (let ((stars (make-string (max 1 (min 9 (or (and (stringp level) (string-to-number level)) level))) ?*)))
                  (insert stars " "))
                
                ;; Add TODO state if provided
                (unless (string-empty-p todo-state)
                  (insert todo-state " "))
                
                ;; Add priority if provided
                (unless (string-empty-p priority)
                  (let ((priority-char (string-to-char (upcase priority))))
                    (when (and (<= ?A priority-char) (>= ?C priority-char))
                      (insert (format "[#%c] " priority-char)))))
                
                ;; Add the heading text
                (insert heading)
                
                ;; Add tags if provided
                (unless (string-empty-p tags)
                  (let ((tag-list (mapcar #'string-trim (split-string tags ","))))
                    (when tag-list
                      (org-set-tags tag-list))))
                
                "Heading created successfully")
            (error (format "Error creating heading: %S" err))))))))

(defun gptel-org-schedule-item (heading date)
  "Schedule the org heading containing HEADING with DATE.
DATE should be in a format that org-mode understands (e.g., \"today\", \"tomorrow\", \"2023-12-31\")."
  (let ((buffer (gptel-get-buffer)))
    (if (not buffer)
        "No active gptel buffer found"
      (with-current-buffer buffer
        (if (not (derived-mode-p 'org-mode))
            "Buffer is not in org-mode"
          (condition-case err
              (save-excursion
                (goto-char (point-min))
                (if (not (re-search-forward (regexp-quote heading) nil t))
                    (format "Heading \"%s\" not found" heading)
                  (org-back-to-heading t)
                  (org-schedule nil date)
                  (format "Item scheduled for %s" date)))
            (error (format "Error scheduling item: %S" err))))))))

;; Register the tools

(gptel-make-tool
 :function #'gptel-org-get-structure
 :name "org_get_structure"
 :description "Get the heading structure of an org file"
 :args (list '(:name "buffer_name"
               :type string
               :description "The name of the buffer (empty string for current buffer)"))
 :category "org-mode")

(gptel-make-tool
 :function #'gptel-org-get-todos
 :name "org_get_todos"
 :description "Get all TODO items from an org file"
 :args (list '(:name "buffer_name"
               :type string
               :description "The name of the buffer (empty string for current buffer)"))
 :category "org-mode")

(gptel-make-tool
 :function #'gptel-org-create-heading
 :name "org_create_heading"
 :description "Create a new org heading in the current buffer"
 :args (list '(:name "heading"
               :type string
               :description "The text of the heading")
              '(:name "level"
                :type string
                :description "The heading level (1-9)")
              '(:name "todo_state"
                :type string
                :description "The TODO state (can be empty)")
              '(:name "tags"
                :type string
                :description "Comma-separated list of tags (can be empty)")
              '(:name "priority"
                :type string
                :description "The priority (A, B, C or empty for default)"))
 :category "org-mode")

(gptel-make-tool
 :function #'gptel-org-schedule-item
 :name "org_schedule_item"
 :description "Schedule an org heading with a date"
 :args (list '(:name "heading"
               :type string
               :description "The heading text to find and schedule")
              '(:name "date"
                :type string
                :description "The date (e.g., 'today', 'tomorrow', '2023-12-31')"))
 :category "org-mode")

(provide 'org-mode-tools)
;;; org-mode-tools.el ends here