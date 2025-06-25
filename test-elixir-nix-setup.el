;;; test-elixir-nix-setup.el --- Test Elixir + Nix + LSP setup with universal wrapper

;;; Commentary:
;; This file tests whether your Elixir + Nix + direnv + LSP setup is working correctly
;; with the universal wrapper approach

;;; Code:

(defun test-elixir-nix-setup ()
  "Test the Elixir + Nix + direnv + LSP setup with universal wrapper."
  (interactive)
  (let ((results '())
        (test-buffer "*Elixir Nix Setup Test Results*"))
    
    ;; Create results buffer
    (with-current-buffer (get-buffer-create test-buffer)
      (erase-buffer)
      (insert "=== Elixir + Nix + direnv + LSP Setup Test (Universal Wrapper) ===\n\n"))
    
    ;; Test 1: Check if direnv/envrc is working
    (let ((envrc-available (featurep 'envrc))
          (envrc-global (bound-and-true-p envrc-global-mode)))
      (push (list "direnv/envrc module" 
                  envrc-available 
                  (if envrc-available "✓ envrc loaded" "✗ envrc not loaded"))
            results)
      (push (list "envrc global mode" 
                  envrc-global 
                  (if envrc-global "✓ envrc-global-mode enabled" "✗ envrc-global-mode disabled"))
            results))
    
    ;; Test 2: Check LSP configuration
    (let ((lsp-available (featurep 'lsp-mode))
          (lsp-elixir-available (featurep 'lsp-elixir)))
      (push (list "LSP mode" 
                  lsp-available 
                  (if lsp-available "✓ lsp-mode loaded" "✗ lsp-mode not loaded"))
            results)
      (push (list "LSP Elixir" 
                  lsp-elixir-available 
                  (if lsp-elixir-available "✓ lsp-elixir loaded" "✗ lsp-elixir not loaded"))
            results))
    
    ;; Test 3: Check wrapper script
    (let ((wrapper-path (expand-file-name "elixir-ls-direnv-wrapper.sh" doom-user-dir)))
      (push (list "Universal wrapper script" 
                  (file-exists-p wrapper-path)
                  (if (file-exists-p wrapper-path) 
                      (format "✓ Found at: %s" wrapper-path)
                    (format "✗ Not found at: %s" wrapper-path)))
            results)
      
      (when (file-exists-p wrapper-path)
        (push (list "Wrapper script executable" 
                    (file-executable-p wrapper-path)
                    (if (file-executable-p wrapper-path) 
                        "✓ Executable" 
                      "✗ Not executable"))
              results)))
    
    ;; Test 4: Check LSP server command configuration
    (when (featurep 'lsp-elixir)
      (let ((server-command lsp-elixir-server-command)
            (wrapper-path (expand-file-name "elixir-ls-direnv-wrapper.sh" doom-user-dir)))
        (push (list "LSP Elixir server command" 
                    (and server-command 
                         (listp server-command)
                         (string= (car server-command) wrapper-path))
                    (format "Current: %s" server-command))
              results)))
    
    ;; Test 5: Check if we're in a direnv-managed directory
    (let ((envrc-file (locate-dominating-file default-directory ".envrc")))
      (push (list "Current directory has .envrc" 
                  envrc-file 
                  (if envrc-file (format "✓ Found .envrc in: %s" envrc-file) "✗ No .envrc found"))
            results))
    
    ;; Test 6: Test wrapper script functionality
    (let ((wrapper-path (expand-file-name "elixir-ls-direnv-wrapper.sh" doom-user-dir)))
      (when (file-executable-p wrapper-path)
        (with-temp-buffer
          (let* ((process-environment (cons "ELIXIR_LS_WRAPPER_DEBUG=1" process-environment))
                 (exit-code (call-process wrapper-path nil t nil "--version"))
                 (output (buffer-string)))
            (push (list "Wrapper script test" 
                        (= exit-code 0)
                        (if (= exit-code 0) 
                            "✓ Wrapper executed successfully"
                          (format "✗ Wrapper failed (exit code: %d)" exit-code)))
                  results)
            
            ;; Store output for detailed analysis
            (push (list "Wrapper debug output" 
                        t
                        (format "Output: %s" (string-trim output)))
                  results)))))
    
    ;; Test 7: Check current environment for Elixir tools
    (let ((elixir-path (executable-find "elixir"))
          (elixir-ls-path (executable-find "elixir-ls"))
          (mix-path (executable-find "mix")))
      (push (list "elixir executable" 
                  elixir-path 
                  (if elixir-path (format "✓ Found at: %s" elixir-path) "✗ Not found in PATH"))
            results)
      (push (list "elixir-ls executable" 
                  elixir-ls-path 
                  (if elixir-ls-path (format "✓ Found at: %s" elixir-ls-path) "✗ Not found in PATH"))
            results)
      (push (list "mix executable" 
                  mix-path 
                  (if mix-path (format "✓ Found at: %s" mix-path) "✗ Not found in PATH"))
            results))
    
    ;; Test 8: Check environment variables
    (let ((nix-store-path (getenv "NIX_STORE"))
          (path-env (getenv "PATH")))
      (push (list "NIX_STORE environment variable" 
                  nix-store-path 
                  (if nix-store-path (format "✓ NIX_STORE: %s" nix-store-path) "✗ NIX_STORE not set"))
            results)
      (when path-env
        (let ((nix-in-path (string-match-p "/nix/store" path-env)))
          (push (list "Nix paths in PATH" 
                      nix-in-path 
                      (if nix-in-path "✓ Nix store paths found in PATH" "✗ No Nix store paths in PATH"))
                results))))
    
    ;; Display results
    (with-current-buffer test-buffer
      (dolist (result (reverse results))
        (let ((test-name (nth 0 result))
              (success (nth 1 result))
              (message (nth 2 result)))
          (insert (format "%-35s %s\n" test-name message))))
      
      (insert "\n=== Analysis ===\n")
      
      ;; Provide analysis based on results
      (let ((wrapper-exists (file-exists-p (expand-file-name "elixir-ls-direnv-wrapper.sh" doom-user-dir)))
            (wrapper-configured (and (featurep 'lsp-elixir)
                                   (listp lsp-elixir-server-command)
                                   (string= (car lsp-elixir-server-command)
                                          (expand-file-name "elixir-ls-direnv-wrapper.sh" doom-user-dir))))
            (in-envrc-dir (locate-dominating-file default-directory ".envrc"))
            (elixir-ls-found (executable-find "elixir-ls")))
        
        (if (and wrapper-exists wrapper-configured)
            (insert "✓ Universal wrapper is properly configured\n")
          (insert "✗ Universal wrapper setup incomplete\n"))
        
        (if in-envrc-dir
            (insert "✓ Currently in a direnv-managed project\n")
          (insert "• Not currently in a direnv-managed project (this is OK for testing)\n"))
        
        (if elixir-ls-found
            (insert "✓ elixir-ls is available in current environment\n")
          (insert "• elixir-ls not found - wrapper will handle this in direnv projects\n")))
      
      (insert "\n=== Recommendations ===\n")
      
      (let ((wrapper-path (expand-file-name "elixir-ls-direnv-wrapper.sh" doom-user-dir)))
        (unless (file-exists-p wrapper-path)
          (insert "• Create the universal wrapper script\n"))
        
        (when (and (file-exists-p wrapper-path) (not (file-executable-p wrapper-path)))
          (insert "• Make wrapper script executable: chmod +x " wrapper-path "\n"))
        
        (unless (and (featurep 'lsp-elixir)
                     (listp lsp-elixir-server-command)
                     (string= (car lsp-elixir-server-command) wrapper-path))
          (insert "• Configure LSP to use wrapper: (setq lsp-elixir-server-command '(\"" wrapper-path "\"))\n")))
      
      (insert "\n=== Next Steps ===\n")
      (insert "1. Ensure the universal wrapper is created and executable\n")
      (insert "2. Load the updated elixir-nix-fix.el configuration\n")
      (insert "3. Test in an Elixir project with .envrc\n")
      (insert "4. Open an Elixir file and run M-x lsp\n")
      (insert "5. Use M-x enable-elixir-ls-wrapper-debug for troubleshooting\n")
      
      (goto-char (point-min)))
    
    ;; Show the results buffer
    (display-buffer test-buffer)
    (message "Test completed! Check the results buffer.")))

(defun test-elixir-project-setup (project-dir)
  "Test Elixir setup in a specific project directory."
  (interactive "DProject directory: ")
  (let ((default-directory (expand-file-name project-dir)))
    (test-elixir-nix-setup)))

(defun test-wrapper-in-project (project-dir)
  "Test the wrapper script specifically in a project directory."
  (interactive "DProject directory: ")
  (let ((default-directory (expand-file-name project-dir)))
    (test-elixir-ls-wrapper)))

(provide 'test-elixir-nix-setup)
;;; test-elixir-nix-setup.el ends here