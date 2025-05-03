;;; adr-tools.el --- Architectural Decision Records management tool -*- lexical-binding: t; -*-

;; Copyright (C) 2023-2024 

;; Author: LLM Assistant
;; Keywords: tools, documentation
;; Version: 0.1

;;; Commentary:

;; This package provides tools for managing Architectural Decision Records (ADRs).
;; It allows creating, listing, and updating ADRs using standard templates.

;;; Code:

(require 'gptel)
(require 'cl-lib)
(require 'seq)
(require 'f)

;;; Customization

(defgroup gptel-adr nil
  "Architectural Decision Records management for gptel."
  :group 'gptel
  :prefix "gptel-adr-")

(defcustom gptel-adr-directory nil
  "Directory to store Architectural Decision Records.
  This will always be set to 'docs/adr' in the current projectile project root."
  :group 'gptel-adr
  :type 'directory)

(defcustom gptel-adr-template
  "# %s

## Status

%s

## Context

[Describe the context and problem statement, e.g., in free form using two to three sentences.
You may want to articulate the problem in form of a question.]

## Decision

[Describe the decision that was made, the approach taken to address the context/problem.]

## Consequences

[What becomes easier or more difficult to do and any risks introduced by the change that will need to be mitigated?]

## References

[Any relevant documentation, articles, or resources that support this decision.]
"
  "Template for new ADRs.
The template is a format string where:
- First %s is replaced with the title
- Second %s is replaced with the status"
  :group 'gptel-adr
  :type 'string)

;;; Internal functions

(defun gptel-adr--ensure-directory ()
  "Ensure the ADR directory exists and return the path.
  Always uses 'docs/adr' in the current projectile project root."
  (let ((dir (expand-file-name "docs/adr" (projectile-project-root))))
    (unless (file-exists-p dir)
      (make-directory dir t))
    dir))

(defun gptel-adr--get-all-adrs ()
  "Get a list of all ADR files sorted by number."
  (let ((files (directory-files (gptel-adr--ensure-directory) t "ADR-[0-9]\\{4\\}.*\\.md$")))
    (seq-sort #'string< files)))

(defun gptel-adr--get-next-number ()
  "Get the next available ADR number."
  (let* ((adrs (gptel-adr--get-all-adrs))
         (max-num 0))
    (dolist (adr adrs)
      (when (string-match "ADR-\\([0-9]+\\)" (file-name-nondirectory adr))
        (let ((num (string-to-number (match-string 1 (file-name-nondirectory adr)))))
          (when (> num max-num)
            (setq max-num num)))))
    (1+ max-num)))

(defun gptel-adr--normalize-title (title)
  "Normalize TITLE for use in a filename."
  (let ((normalized (downcase title)))
    ;; Replace spaces with hyphens
    (setq normalized (replace-regexp-in-string " " "-" normalized))
    ;; Remove any invalid file name characters
    (setq normalized (replace-regexp-in-string "[^a-z0-9-]" "" normalized))
    normalized))

(defun gptel-adr--get-filename (number title)
  "Create a filename for ADR with NUMBER and TITLE."
  (let ((normalized-title (gptel-adr--normalize-title title)))
    (format "ADR-%04d-%s.md" number normalized-title)))

(defun gptel-adr--get-title-from-file (file)
  "Extract title from FILE."
  (with-temp-buffer
    (insert-file-contents file)
    (goto-char (point-min))
    (when (re-search-forward "^# \\(.*\\)$" nil t)
      (match-string 1))))

(defun gptel-adr--get-status-from-file (file)
  "Extract status from FILE."
  (with-temp-buffer
    (insert-file-contents file)
    (goto-char (point-min))
    (when (re-search-forward "^## Status\\s-*\n\\s-*\\(.*\\)$" nil t)
      (match-string 1))))

(defun gptel-adr--update-status-in-file (file new-status)
  "Update status in FILE to NEW-STATUS."
  (with-temp-buffer
    (insert-file-contents file)
    (goto-char (point-min))
    (when (re-search-forward "^## Status\\s-*\n\\s-*\\(.*\\)$" nil t)
      (replace-match new-status t t nil 1)
      (write-region (point-min) (point-max) file))))

;;; Interactive functions

(defun gptel-adr-create (title status)
  "Create a new ADR with TITLE and STATUS.
Returns the path to the created ADR file."
  (let* ((dir (gptel-adr--ensure-directory))
         (number (gptel-adr--get-next-number))
         (filename (gptel-adr--get-filename number title))
         (filepath (expand-file-name filename dir))
         (content (format gptel-adr-template title status)))
    (if (file-exists-p filepath)
        (error "ADR already exists: %s" filepath)
      (with-temp-file filepath
        (insert content))
      filepath)))

(defun gptel-adr-list ()
  "List all ADRs with their numbers, titles, and statuses.
Returns a formatted string with the list."
  (let ((adrs (gptel-adr--get-all-adrs))
        (result ""))
    (if (null adrs)
        "No ADRs found. Create your first one with the adr_create tool."
      (setq result "# Architectural Decision Records\n\n")
      (dolist (adr adrs)
        (let* ((filename (file-name-nondirectory adr))
               (title (or (gptel-adr--get-title-from-file adr) "Unknown Title"))
               (status (or (gptel-adr--get-status-from-file adr) "Unknown Status")))
          (setq result (concat result (format "- **%s**: %s (%s)\n" 
                                             (file-name-sans-extension filename)
                                             title
                                             status)))))
      result)))

(defun gptel-adr-update-status (adr-number new-status)
  "Update the status of ADR-NUMBER to NEW-STATUS.
Returns a confirmation message."
  (let* ((dir (gptel-adr--ensure-directory))
         (adrs (gptel-adr--get-all-adrs))
         (matching-adr nil))
    ;; Find the matching ADR
    (dolist (adr adrs)
      (when (string-match (format "ADR-%04d" adr-number) (file-name-nondirectory adr))
        (setq matching-adr adr)))
    
    (if matching-adr
        (progn
          (gptel-adr--update-status-in-file matching-adr new-status)
          (format "Updated ADR-%04d status to: %s" adr-number new-status))
      (format "Error: ADR-%04d not found" adr-number))))

(defun gptel-adr-view (adr-number)
  "View the content of ADR-NUMBER.
Returns the content of the ADR as a string."
  (let* ((dir (gptel-adr--ensure-directory))
         (adrs (gptel-adr--get-all-adrs))
         (matching-adr nil))
    ;; Find the matching ADR
    (dolist (adr adrs)
      (when (string-match (format "ADR-%04d" adr-number) (file-name-nondirectory adr))
        (setq matching-adr adr)))
    
    (if matching-adr
        (with-temp-buffer
          (insert-file-contents matching-adr)
          (buffer-string))
      (format "Error: ADR-%04d not found" adr-number))))

;;; Register tools with gptel

(gptel-make-tool
 :function #'gptel-adr-create
 :name "adr_create"
 :description "Create a new Architectural Decision Record (ADR)"
 :args (list '(:name "title"
                :type string
                :description "The title of the ADR (e.g., 'Use PostgreSQL for Database')")
             '(:name "status"
                :type string
                :description "The initial status of the ADR (e.g., 'Proposed', 'Accepted', 'Rejected')"))
 :category "documentation")

(gptel-make-tool
 :function #'gptel-adr-list
 :name "adr_list"
 :description "List all Architectural Decision Records with their statuses"
 :args nil
 :category "documentation")

(gptel-make-tool
 :function #'gptel-adr-update-status
 :name "adr_update_status"
 :description "Update the status of an existing Architectural Decision Record"
 :args (list '(:name "adr_number"
                :type number
                :description "The ADR number to update (without the 'ADR-' prefix)")
             '(:name "new_status"
                :type string
                :description "The new status (e.g., 'Accepted', 'Rejected', 'Deprecated')"))
 :category "documentation")

(gptel-make-tool
 :function #'gptel-adr-view
 :name "adr_view"
 :description "View the content of an Architectural Decision Record"
 :args (list '(:name "adr_number"
                :type number
                :description "The ADR number to view (without the 'ADR-' prefix)"))
 :category "documentation")

(provide 'adr-tools)
;;; adr-tools.el ends here