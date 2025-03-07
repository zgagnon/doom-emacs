;;; gptel-tools-file.el --- File manipulation tools for gptel -*- lexical-binding: t; -*-

;;; Commentary:
;; Provides tools for file creation and manipulation

;;; Code:
(require 'gptel)

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

(provide 'gptel-tools-file)
;;; gptel-tools-file.el ends here
