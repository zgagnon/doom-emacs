;;; envrc-fix.el --- Fix envrc to properly update exec-path

;;; Commentary:
;; This file provides a fix for envrc to ensure that exec-path is properly
;; synchronized with the PATH environment variable when direnv loads a new
;; environment.

;;; Code:

(defun my/sync-exec-path-from-path ()
  "Synchronize `exec-path' with the PATH environment variable."
  (let ((path-dirs (split-string (getenv "PATH") path-separator t)))
    (setq exec-path (append path-dirs (list exec-directory)))))

(defun my/envrc-after-update-hook ()
  "Hook to run after envrc updates the environment.
This ensures that exec-path is synchronized with PATH."
  (my/sync-exec-path-from-path)
  (message "Updated exec-path from PATH environment variable"))

;; Add the hook to run after envrc updates the environment
(with-eval-after-load 'envrc
  (add-hook 'envrc-mode-hook #'my/envrc-after-update-hook)
  ;; Also run it when envrc updates the environment
  (advice-add 'envrc--update :after #'my/envrc-after-update-hook))

;; Function to manually sync if needed
(defun my/manual-sync-exec-path ()
  "Manually synchronize exec-path with PATH environment variable."
  (interactive)
  (my/sync-exec-path-from-path)
  (message "Manually synchronized exec-path with PATH"))

;; Function to check current status
(defun my/check-elixir-environment ()
  "Check if Elixir and elixir-ls are available in the current environment."
  (interactive)
  (let ((elixir-path (executable-find "elixir"))
        (elixir-ls-path (executable-find "elixir-ls"))
        (path-env (getenv "PATH")))
    (message "Elixir: %s\nElixir-LS: %s\nPATH contains nix store: %s"
             (or elixir-path "NOT FOUND")
             (or elixir-ls-path "NOT FOUND")
             (if (string-match-p "/nix/store" path-env) "YES" "NO"))))

(provide 'envrc-fix)
;;; envrc-fix.el ends here