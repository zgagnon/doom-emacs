;;; test-universal-elixir-setup.el --- Comprehensive test for universal Elixir setup

(defun test-universal-elixir-setup ()
  "Comprehensive test of the universal Elixir setup across multiple projects."
  (interactive)
  (let ((test-projects '("/Users/zell/git/mo/imogen" "/Users/zell/git/mo/alpacka"))
        (test-buffer "*Universal Elixir Setup Test*"))
    
    ;; Create results buffer
    (with-current-buffer (get-buffer-create test-buffer)
      (erase-buffer)
      (insert "=== Universal Elixir + Nix + direnv + LSP Setup Test ===\n\n"))
    
    ;; Test each project
    (dolist (project test-projects)
      (when (file-directory-p project)
        (let ((default-directory project))
          (with-current-buffer test-buffer
            (insert (format "Testing project: %s\n" project))
            (insert "----------------------------------------\n"))
          
          ;; Test wrapper functionality
          (let ((wrapper-path (expand-file-name "elixir-ls-direnv-wrapper.sh" doom-user-dir)))
            (when (file-executable-p wrapper-path)
              (with-temp-buffer
                (let* ((process-environment (cons "ELIXIR_LS_WRAPPER_DEBUG=1" process-environment))
                       (exit-code (call-process wrapper-path nil t nil "--version"))
                       (output (buffer-string)))
                  
                  (with-current-buffer test-buffer
                    (insert (format "Wrapper exit code: %d\n" exit-code))
                    (if (= exit-code 0)
                        (insert "✓ Wrapper executed successfully\n")
                      (insert "✗ Wrapper failed\n"))
                    
                    ;; Extract key information from output
                    (when (string-match "Found .envrc in: \\([^\n]+\\)" output)
                      (insert (format "✓ Found .envrc in: %s\n" (match-string 1 output))))
                    
                    (when (string-match "Started ElixirLS \\([^\n\"]+\\)" output)
                      (insert (format "✓ ElixirLS version: %s\n" (match-string 1 output))))
                    
                    (when (string-match "Running on elixir \"\\([^\"]+\\)\"" output)
                      (insert (format "✓ Elixir version: %s\n" (match-string 1 output))))
                    
                    (insert "\n")))))
          
          ;; Test environment
          (let ((envrc-file (locate-dominating-file default-directory ".envrc")))
            (with-current-buffer test-buffer
              (if envrc-file
                  (insert (format "✓ .envrc found in: %s\n" envrc-file))
                (insert "✗ No .envrc found\n"))))
          
          (with-current-buffer test-buffer
            (insert "\n")))))
    
    ;; Overall configuration test
    (with-current-buffer test-buffer
      (insert "=== Global Configuration ===\n")
      
      (let ((wrapper-path (expand-file-name "elixir-ls-direnv-wrapper.sh" doom-user-dir)))
        (if (file-executable-p wrapper-path)
            (insert (format "✓ Universal wrapper: %s\n" wrapper-path))
          (insert (format "✗ Universal wrapper not found: %s\n" wrapper-path))))
      
      (if (and (featurep 'lsp-elixir)
               (listp lsp-elixir-server-command)
               (string= (car lsp-elixir-server-command)
                       (expand-file-name "elixir-ls-direnv-wrapper.sh" doom-user-dir)))
          (insert "✓ LSP configured to use universal wrapper\n")
        (insert "✗ LSP not configured to use universal wrapper\n"))
      
      (insert "\n=== Summary ===\n")
      (insert "The universal wrapper approach provides:\n")
      (insert "• Automatic detection of direnv environments\n")
      (insert "• No per-project configuration required\n")
      (insert "• Consistent behavior across all Elixir projects\n")
      (insert "• Graceful fallback for non-direnv projects\n")
      (insert "\nTo use:\n")
      (insert "1. Open any Elixir file in a project with .envrc\n")
      (insert "2. Run M-x lsp\n")
      (insert "3. ElixirLS will automatically use the correct environment\n"))
    
    ;; Show results
    (display-buffer test-buffer)
    (message "Universal Elixir setup test completed!")))

(provide 'test-universal-elixir-setup)