;;; gptel-tools-buffer.el --- Buffer manipulation tools for gptel -*- lexical-binding: t; -*-

;;; Commentary:
;; Provides tools for reading Emacs buffers

;;; Code:
(require 'gptel)

;; Basic buffer reading tool
(gptel-make-tool
 :name "read_buffer"
 :function (lambda (buffer)
             (unless (buffer-live-p (get-buffer buffer))
               (error "Error: buffer %s is not live." buffer))
             (with-current-buffer buffer
               (buffer-substring-no-properties (point-min) (point-max))))
 :description "return the contents of an emacs buffer"
 :args (list '(:name "buffer"
               :type string
               :description "the name of the buffer whose contents are to be retrieved"))
 :category "emacs")

(provide 'gptel-tools-buffer)
;;; gptel-tools-buffer.el ends here
