;;; lisp-formatting.el --- Configure Lisp code formatting -*- lexical-binding: t; -*-
;;
;; This file configures Lisp code formatting to match the style in gptel
;;

;;; Commentary:
;; Configuration for Lisp code formatting based on gptel style

;;; Code:

;; Basic indentation settings
(setq-default tab-width 2
              indent-tabs-mode nil)

;; Lisp-specific indentation settings
(use-package! lisp-mode
  :config
  (setq lisp-indent-function 'common-lisp-indent-function)
  (setq lisp-indent-offset 2))

;; Configure smartparens for Lisp modes
(after! smartparens
  ;; Show matching pairs without extra spaces
  (setq sp-show-pair-from-inside t)
  
  ;; Turn off automatic newlines in smartparens
  (setq sp-autoskip-closing-pair 'always)
  (setq sp-autoskip-opening-pair nil)
  (setq sp-autoinsert-quote-if-followed-by-closing-pair t)
  
  ;; Don't pair quotes inside comments or strings
  (sp-local-pair '(emacs-lisp-mode lisp-mode lisp-interaction-mode) "'" nil
                 :unless '(sp-in-string-p sp-in-comment-p))
  
  ;; Configure spacing for Lisp modes
  (dolist (mode '(emacs-lisp-mode lisp-mode lisp-interaction-mode))
    ;; Don't add spaces around parentheses
    (sp-local-pair mode "(" ")" :post-handlers '(:rem sp-add-space-after-insert))
    
    ;; Don't add spaces around square brackets
    (sp-local-pair mode "[" "]" :post-handlers '(:rem sp-add-space-after-insert))
    
    ;; Don't add spaces around curly braces
    (sp-local-pair mode "{" "}" :post-handlers '(:rem sp-add-space-after-insert)))
  
  ;; Customize parentheses behavior for clean formatting
  (sp-with-modes sp-lisp-modes
    ;; Don't automatically escape quotes
    (sp-local-pair "'" nil :actions nil)
    ;; Handle backtick correctly for Lisp quoting
    (sp-local-pair "`" "'" :when '(sp-in-string-p))))

;; Configure common special forms indentation
(after! elisp-mode
  (put 'if-let* 'lisp-indent-function 2)
  (put 'when-let* 'lisp-indent-function 1)
  (put 'thread-first 'lisp-indent-function 1)
  (put 'thread-last 'lisp-indent-function 1)
  (put 'cl-defmethod 'lisp-indent-function 'defun)
  (put 'cl-defgeneric 'lisp-indent-function 'defun)
  (put 'pcase-let 'lisp-indent-function 2)
  (put 'pcase-let* 'lisp-indent-function 2)
  (put 'pcase 'lisp-indent-function 1)
  (put 'gv-letplace 'lisp-indent-function 2)
  
  ;; gptel-specific indentations if you edit that code
  (put 'gptel-with-curl-buffer 'lisp-indent-function 'defun)
  (put 'gptel-with-callback 'lisp-indent-function 'defun))

;; Set up electric-pair-mode for automatic pairing
(use-package! elec-pair
  :hook ((emacs-lisp-mode lisp-mode) . electric-pair-local-mode)
  :config
  (setq electric-pair-preserve-balance t
        electric-pair-delete-adjacent-pairs t
        electric-pair-open-newline-between-pairs nil))

;; Special function to reformat a buffer
(defun my-indent-elisp-buffer ()
  "Indent current elisp buffer according to style."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (not (eobp))
      (if (or (nth 4 (syntax-ppss)) ;; Inside comment
              (and (not (nth 4 (syntax-ppss))) 
                   (looking-at-p "[\s\t]*;"))) ;; Line with comment
        (forward-line 1)
        (lisp-indent-line)
        (forward-line 1)))))

;; Add a key binding for reformatting
;; Uncomment the following line if you want to bind to SPC c f
;; (map! :leader :desc "Format elisp buffer" "c f" #'my-indent-elisp-buffer)

(provide 'lisp-formatting)
;;; lisp-formatting.el ends here