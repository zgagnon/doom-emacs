;;; gptel-open-file.el --- Tool to open a file in a buffer for gptel

(defun gptel-open-file (filepath)
  "Open FILEPATH in a new buffer and return buffer name."
  (let ((buf (find-file-noselect filepath)))
    (buffer-name buf)))

(provide 'gptel-open-file)
;;; gptel-open-file.el ends here
