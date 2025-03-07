;;; gptel-langchain.el --- LLM-powered chain workflows for gptel

(defvar gptel-langchain-chains (make-hash-table :test 'equal)
  "Stores all defined langchains.")

(defun gptel-langchain-define-chain (name steps)
  "Define a new langchain called NAME with STEPS."
  (puthash name steps gptel-langchain-chains))

(defun gptel-langchain-run-chain (name &optional initial-input)
  "Run the chain named NAME, passing INITIAL-INPUT to its first step."
  (let* ((steps (gethash name gptel-langchain-chains))
         (input initial-input)
         (result nil))
    (dolist (step steps)
      (let* ((fn   (plist-get step :function))
             (args (plist-get step :args)))
        (setq result (apply fn (append (when input (list input)) args)))
        (setq input result)))
    result))

;; Example: Define a chain that searches then summarizes
;; (gptel-langchain-define-chain
;;  "search-and-summarize"
;;  '((:function gptel-search :args nil)
;;    (:function gptel-summarize :args nil)))

(provide 'gptel-langchain)
;;; gptel-langchain.el ends here
