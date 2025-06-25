;;; elixir-nix-fix.el --- Universal fix for Elixir + Nix + direnv + LSP

;;; Commentary:
;; This file provides a universal solution for making Elixir work with Nix and direnv in Emacs
;; Uses a global wrapper script that automatically detects direnv environments

;;; Code:

(defvar elixir-ls-direnv-wrapper-path
  (expand-file-name "elixir-ls-direnv-wrapper.sh" doom-user-dir)
  "Path to the universal elixir-ls direnv wrapper script.")

(defun my/setup-elixir-lsp-with-direnv-wrapper ()
  "Setup Elixir LSP to use the universal direnv wrapper."
  (when (file-executable-p elixir-ls-direnv-wrapper-path)
    (setq lsp-elixir-server-command (list elixir-ls-direnv-wrapper-path))
    (message "Elixir LSP configured to use direnv wrapper: %s" elixir-ls-direnv-wrapper-path))
  
  (unless (file-executable-p elixir-ls-direnv-wrapper-path)
    (message "Warning: Elixir-LS direnv wrapper not found or not executable: %s" 
             elixir-ls-direnv-wrapper-path)))

;; Configure LSP to use the wrapper as soon as lsp-elixir is loaded
(with-eval-after-load 'lsp-elixir
  (my/setup-elixir-lsp-with-direnv-wrapper))

;; Also set it up immediately if lsp-elixir is already loaded
(when (featurep 'lsp-elixir)
  (my/setup-elixir-lsp-with-direnv-wrapper))

;; Enhanced test function
(defun test-and-fix-elixir-nix-setup ()
  "Test and attempt to fix Elixir + Nix setup issues."
  (interactive)
  (message "Testing Elixir + Nix setup with universal wrapper...")
  
  ;; Ensure wrapper is configured
  (my/setup-elixir-lsp-with-direnv-wrapper)
  
  ;; Run the test
  (test-elixir-nix-setup)
  
  ;; If LSP is running, restart it to pick up new configuration
  (when (and (featurep 'lsp-mode) (lsp-workspaces))
    (message "Restarting LSP workspace to apply new configuration...")
    (lsp-restart-workspace)))

;; Debug function to test the wrapper directly
(defun test-elixir-ls-wrapper (&optional directory)
  "Test the elixir-ls wrapper script directly."
  (interactive)
  (let* ((test-dir (or directory default-directory))
         (default-directory test-dir)
         (wrapper-path elixir-ls-direnv-wrapper-path))
    
    (if (not (file-executable-p wrapper-path))
        (message "Error: Wrapper script not found or not executable: %s" wrapper-path)
      
      (message "Testing wrapper in directory: %s" test-dir)
      
      ;; Test with debug mode enabled
      (let ((process-environment (cons "ELIXIR_LS_WRAPPER_DEBUG=1" process-environment)))
        (with-temp-buffer
          (let ((exit-code (call-process wrapper-path nil t nil "--version")))
            (message "Wrapper test output:\n%s" (buffer-string))
            (message "Exit code: %d" exit-code)))))))

;; Function to enable debug mode for the wrapper
(defun enable-elixir-ls-wrapper-debug ()
  "Enable debug mode for the elixir-ls wrapper."
  (interactive)
  (setenv "ELIXIR_LS_WRAPPER_DEBUG" "1")
  (message "Elixir-LS wrapper debug mode enabled"))

(defun disable-elixir-ls-wrapper-debug ()
  "Disable debug mode for the elixir-ls wrapper."
  (interactive)
  (setenv "ELIXIR_LS_WRAPPER_DEBUG" "0")
  (message "Elixir-LS wrapper debug mode disabled"))

(provide 'elixir-nix-fix)
;;; elixir-nix-fix.el ends here