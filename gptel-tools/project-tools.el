;;; project-tools.el --- Project management tools for gptel -*- lexical-binding: t; -*-

;;; Commentary:
;; Provides tools for project-related operations using projectile

;;; Code:
(require 'gptel)
(require 'projectile)

(gptel-make-tool
 :function (lambda ()
             (if (projectile-project-p)
                 (let ((project-root (projectile-project-root)))
                   (format "Current project root: %s" project-root))
               "Not in a projectile project"))
 :name "get_project_root"
 :description "Returns the current project root directory using projectile"
 :args nil
 :category "project")
 
;; Additional project tools can be added here

(provide 'project-tools)
;;; project-tools.el ends here