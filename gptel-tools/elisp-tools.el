;;; elisp-tools.el --- Elisp evaluation tools for gptel -*- lexical-binding: t; -*-

;;; Commentary:
;; Provides tools for Emacs Lisp code evaluation

;;; Code:
(require 'gptel)

(defun gptel-tools--safe-eval-elisp (expr &optional context)
  "Safely evaluate Elisp expression EXPR with optional CONTEXT.
CONTEXT can be 'buffer for current buffer context or nil for a safe evaluation."
  (with-temp-buffer
    (let ((inhibit-message t)
          (message-log-max nil)
          (result nil)
          (err-msg nil))
      (condition-case err
          (pcase context
            ('buffer
             ;; Evaluate in the context of the gptel buffer
             (when-let ((gptel-buffer (gptel-get-buffer)))
               (with-current-buffer gptel-buffer
                 (setq result (eval (read expr))))))
            (_ 
             ;; Safer evaluation without buffer context
             (setq result (eval (read expr)))))
        (error (setq err-msg (format "Evaluation error: %S" err))))
      
      (cond
       (err-msg
        (format "Error: %s" err-msg))
       ((stringp result)
        result)
       (t
        (format "%S" result))))))

(gptel-make-tool
 :function (lambda (expr)
            (gptel-tools--safe-eval-elisp expr))
 :name "evaluate_elisp"
 :description "Evaluate Emacs Lisp expressions safely"
 :args (list '(:name "expression"
               :type string
               :description "The Emacs Lisp expression to evaluate"))
 :category "emacs")

(gptel-make-tool
 :function (lambda (expr)
            (gptel-tools--safe-eval-elisp expr 'buffer))
 :name "evaluate_elisp_in_buffer"
 :description "Evaluate Emacs Lisp expressions in the current gptel buffer context"
 :args (list '(:name "expression"
               :type string
               :description "The Emacs Lisp expression to evaluate in the current buffer context"))
 :category "emacs")

(provide 'elisp-tools)
;;; elisp-tools.el ends here