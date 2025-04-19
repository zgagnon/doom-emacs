;;; file-tools.el --- File manipulation tools for gptel -*- lexical-binding: t; -*-

;;; Commentary:
;; Provides tools for file operations: creation, moving, and directory listing

;;; Code:
(require 'gptel)
(require 'projectile)

(gptel-make-tool
 :function (lambda (filepath)
             (with-temp-buffer
               (insert-file-contents (expand-file-name filepath))
               (buffer-string)))
 :name "read_file"
 :description "Read and display the contents of a file"
 :args (list '(:name "filepath"
               :type string
               :description "Path to the file to read. Supports relative paths and ~."))
 :category "filesystem")

;; File creation tool
(gptel-make-tool
 :name "create_file"
 :function (lambda (path filename content)
             (let ((full-path (expand-file-name filename path)))
               (with-temp-buffer
                 (insert content)
                 (write-file full-path))
               (format "Created file %s in %s" filename path)))
 :description "Create a new file with the specified content"
 :args (list '(:name "path"
               :type string
               :description "The directory where to create the file")
             '(:name "filename"
               :type string
               :description "The name of the file to create")
             '(:name "content"
               :type string
               :description "The content to write to the file"))
 :category "filesystem")

;; File movement/renaming tool constrained to current projectile project
(gptel-make-tool
 :name "move_file"
 :function (lambda (source-path destination-path)
             ;; Ensure we're in a projectile project
             (unless (projectile-project-p)
               (error "Not in a projectile project"))
             
             ;; Get project root and normalize paths
             (let* ((project-root (projectile-project-root))
                    (source-full-path (expand-file-name source-path project-root))
                    (dest-full-path (expand-file-name destination-path project-root))
                    (source-rel-path (file-relative-name source-full-path project-root))
                    (dest-rel-path (file-relative-name dest-full-path project-root)))
               
               ;; Safety checks
               (unless (string-prefix-p project-root source-full-path)
                 (error "Error: Source path %s is outside the current project" source-path))
               
               (unless (string-prefix-p project-root dest-full-path)
                 (error "Error: Destination path %s is outside the current project" destination-path))
               
               ;; Check if source file exists
               (unless (file-exists-p source-full-path)
                 (error "Error: Source file %s does not exist" source-path))
               
               ;; Create destination directory if it doesn't exist
               (let ((dest-dir (file-name-directory dest-full-path)))
                 (when (and dest-dir (not (file-exists-p dest-dir)))
                   (make-directory dest-dir t)))
               
               ;; Perform the move/rename operation
               (rename-file source-full-path dest-full-path)
               
               ;; Update any open buffers
               (when-let ((buffer (find-buffer-visiting source-full-path)))
                 (with-current-buffer buffer
                   (set-visited-file-name dest-full-path nil t)))
               
               ;; Return success message
               (format "Successfully moved file from '%s' to '%s'" source-rel-path dest-rel-path)))
 :description "Move or rename a file within the current projectile project"
 :args (list '(:name "source-path"
               :type string
               :description "Relative path to the source file within the project")
             '(:name "destination-path"
               :type string
               :description "Relative path to the destination within the project"))
 :category "filesystem")

;; Directory listing tool constrained to current projectile project
(gptel-make-tool
 :name "list_directory"
 :function (lambda (dir &optional recursive pattern)
             ;; Ensure we're in a projectile project
             (unless (projectile-project-p)
               (error "Not in a projectile project"))
             
             ;; Get project root and normalize paths
             (let* ((project-root (projectile-project-root))
                    (target-dir (expand-file-name (or dir ".") project-root))
                    (rel-path (file-relative-name target-dir project-root)))
               
               ;; Ensure the target directory is within the project
               (unless (string-prefix-p project-root target-dir)
                 (error "Error: Directory %s is outside the current project %s" dir project-root))
               
               ;; Ensure the directory exists
               (unless (file-directory-p target-dir)
                 (error "Error: %s is not a valid directory" dir))
               
               ;; Get directory contents
               (let ((files (if recursive
                                (directory-files-recursively target-dir (or pattern ".*"))
                              (directory-files target-dir t (or pattern ".*") t)))
                     (result-buffer (get-buffer-create "*directory-listing*")))
                 
                 ;; Create a formatted output in the result buffer
                 (with-current-buffer result-buffer
                   (erase-buffer)
                   (insert (format "Directory listing for: %s\n" rel-path))
                   (insert (format "Project root: %s\n\n" project-root))
                   
                   ;; Add mode information and format the output
                   (insert "Mode          Size               Modified             Name\n")
                   (insert "------------- ------------------ -------------------- ------------------------\n")
                   
                   ;; For each file, get and format details
                   (dolist (file files)
                     (let* ((attrs (file-attributes file))
                            (type (car attrs))
                            (mode-string (if (stringp type)
                                             "l" ; symbolic link
                                           (if (file-directory-p file)
                                               "d" ; directory
                                             "-"))) ; regular file
                            (size (file-attribute-size attrs))
                            (mod-time (format-time-string "%Y-%m-%d %H:%M:%S" (file-attribute-modification-time attrs)))
                            (name (if recursive
                                      (file-relative-name file project-root)
                                    (file-name-nondirectory file))))
                       
                       (insert (format "%s%-12s %18d %20s %s\n"
                                       mode-string
                                       (if (file-directory-p file) "directory" "file")
                                       size
                                       mod-time
                                       name))))

                   ;; Add the buffer to gptel context
                   (gptel-add (current-buffer))
                   (display-buffer (current-buffer))
                   
                   ;; Return a summary with count of files found
                   (format "Listed %d items from directory '%s' in the current project. Results added to context."
                           (length files) rel-path)))))

 (gptel-make-tool
  :function (lambda (parent name)
              (condition-case nil
                  (progn
                    (make-directory (expand-file-name name parent) t)
                    (format "Directory %s created/verified in %s" name parent))
                (error (format "Error creating directory %s in %s" name parent))))
  :name "make_directory"
  :description "Create a new directory with the given name in the specified parent directory"
  :args (list '(:name "parent"
                :type string
                :description "The parent directory where the new directory should be created, e.g. /tmp")
              '(:name "name"
                :type string
                :description "The name of the new directory to create, e.g. testdir"))
  :category "filesystem")

 (defun my-gptel--edit_file (file-path file-edits)
   "In FILE-PATH, apply FILE-EDITS with pattern matching and replacing."
   (if (and file-path (not (string= file-path "")) file-edits)
       (with-current-buffer (get-buffer-create "*edit-file*")
         (insert-file-contents (expand-file-name file-path))
         (let ((inhibit-read-only t)
               (case-fold-search nil)
               (file-name (expand-file-name file-path))
               (edit-success nil))
           ;; apply changes
           (dolist (file-edit (seq-into file-edits 'list))
             (when-let ((line-number (plist-get file-edit :line_number))
                        (old-string (plist-get file-edit :old_string))
                        (new-string (plist-get file-edit :new_string))
                        (is-valid-old-string (not (string= old-string ""))))
               (goto-char (point-min))
               (forward-line (1- line-number))
               (when (search-forward old-string nil t)
                 (replace-match new-string t t)
                 (setq edit-success t))))
           ;; return result to gptel
           (if edit-success
               (progn
                 ;; show diffs
                 (ediff-buffers (find-file-noselect file-name) (current-buffer))
                 (format "Successfully edited %s" file-name))
             (format "Failed to edited %s" file-name))))
     (format "Failed to edited %s" file-path)))

 (gptel-make-tool
  :function #'my-gptel--edit_file
  :name "edit_file"
  :description "Edit file with a list of edits, each edit contains a line-number,
a old-string and a new-string, new-string will replace the old-string at the specified line."
  :args (list '(:name "file-path"
                :type string
                :description "The full path of the file to edit")
              '(:name "file-edits"
                :type array
                :items (:type object
                        :properties
                        (:line_number
                         (:type integer :description "The line number of the file where edit starts.")
                         :old_string
                         (:type string :description "The old-string to be replaced.")
                         :new_string
                         (:type string :description "The new-string to replace old-string.")))
                :description "The list of edits to apply on the file"))
  :category "filesystem")

 :description "List contents of a directory within the current projectile project"
 :args (list '(:name "dir"
               :type string
               :description "Relative directory path within the project (default: project root)")
             '(:name "recursive"
               :type boolean
               :description "Whether to list directories recursively"
               :optional t)
             '(:name "pattern"
               :type string
               :description "Optional file pattern to filter results (regex pattern)"
               :optional t))
 :category "filesystem")

(provide 'file-tools)
;;; file-tools.el ends here
