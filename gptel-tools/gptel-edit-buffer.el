(gptel-make-tool
 :name "edit_buffer"                    ; javascript-style snake_case name
 :function (lambda (buffer content replace-all)  ; the function that will run
             (unless (buffer-live-p (get-buffer buffer))
               (error "error: buffer %s is not live." buffer))
             (with-current-buffer buffer
               (let ((inhibit-read-only t))
                 (if replace-all
                     (progn
                       (erase-buffer)
                       (insert content))
                   (insert content)))
               (format "Edited buffer %s" buffer)))
 :description "Edit the contents of an emacs buffer"
 :args (list '(:name "buffer"
               :type string            ; :type value must be a symbol
               :description "the name of the buffer to edit")
             '(:name "content"
               :type string
               :description "the content to insert into the buffer")
             '(:name "replace-all"
               :type boolean
               :description "if true, replace entire buffer content; if false, insert at point"))
 :category "emacs")                     ; An arbitrary label for grouping

(provide 'gptel-edit-buffer)
