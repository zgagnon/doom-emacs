;;; gptel-tools-move.el --- File movement tools for gptel -*- lexical-binding: t; -*-

;;; Commentary:
;; Provides tools for moving and renaming files

;;; Code:
(require 'gptel)
(require 'projectile)

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

(provide 'gptel-tools-move)
;;; gptel-tools-move.el ends here
