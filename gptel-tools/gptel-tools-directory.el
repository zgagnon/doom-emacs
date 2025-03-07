;;; gptel-tools-directory.el --- Directory listing tools for gptel -*- lexical-binding: t; -*-

;;; Commentary:
;; Provides tools for listing directory contents

;;; Code:
(require 'gptel)
(require 'projectile)

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

(provide 'gptel-tools-directory)
;;; gptel-tools-directory.el ends here
