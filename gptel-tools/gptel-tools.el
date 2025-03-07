;; gptel-tools.el - Custom tools for gptel

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

;; DuckDuckGo search tool using curl
(gptel-make-tool
 :name "search_duckduckgo"
 :function (lambda (query)
             (let ((url (format "https://duckduckgo.com/html/?q=%s" 
                               (url-hexify-string query)))
                   (buffer-name "*duckduckgo-results*"))
               ;; Create a buffer for results
               (with-current-buffer (get-buffer-create buffer-name)
                 (erase-buffer)
                 (insert (format "DuckDuckGo search results for: %s\n\n" query))
                 
                 ;; Use curl to fetch the results
                 (let ((curl-cmd (format "curl -s \"%s\" -A \"Mozilla/5.0\"" url)))
                   (call-process-shell-command curl-cmd nil t)
                   
                   ;; Basic HTML cleanup for readability (very simple)
                   (goto-char (point-min))
                   (while (re-search-forward "<[^>]*>" nil t)
                     (replace-match " "))
                   
                   ;; Remove extra whitespace
                   (goto-char (point-min))
                   (while (re-search-forward "\\s-+" nil t)
                     (replace-match " "))
                   
                   ;; Add the buffer to gptel context
                   (gptel-add (current-buffer))
                   (display-buffer (current-buffer))
                   
                   ;; Return a summary
                   (format "DuckDuckGo search results for '%s' have been fetched using curl and added to context." query)))))
 :description "search duckduckgo for information and add results to context"
 :args (list '(:name "query"
               :type string
               :description "the search query to submit to duckduckgo"))
 :category "web")

;; File creation tool
(gptel-make-tool
 :name "create_file"
 :function (lambda (path filename content)
             (let ((full-path (expand-file-name filename path)))
               (with-temp-buffer
                 (insert content)
                 (write-file full-path))
               (format "Created file %s in %s" filename path)))
 :description "Create a new file with the specified content"
 :args (list '(:name "path"
               :type string
               :description "The directory where to create the file")
             '(:name "filename"
               :type string
               :description "The name of the file to create")
             '(:name "content"
               :type string
               :description "The content to write to the file"))
 :category "filesystem")

;; Ripgrep search and context tool
(gptel-make-tool
 :name "search_and_context"
 :function (lambda (pattern dir &optional file-pattern)
             (let* ((default-directory (expand-file-name dir))
                    (file-arg (if file-pattern (concat "--glob=" file-pattern) ""))
                    (cmd (format "rg --color never --line-number --no-heading %s %s"
                                 file-arg (shell-quote-argument pattern)))
                    (results (shell-command-to-string cmd))
                    (matches (split-string results "\n" t))
                    (files-opened '())
                    (context-added '()))
               
               ;; Display the search results in a buffer for reference
               (with-current-buffer (get-buffer-create "*ripgrep-results*")
                 (erase-buffer)
                 (insert (format "Search results for pattern: %s\nin directory: %s\n\n" 
                                pattern (expand-file-name dir)))
                 (insert results)
                 (display-buffer (current-buffer)))
               
               ;; Parse results and open files
               (dolist (match matches)
                 (when (string-match "^\\([^:]+\\):\\([0-9]+\\):" match)
                   (let* ((file (match-string 1 match))
                          (line (string-to-number (match-string 2 match)))
                          (abs-path (expand-file-name file default-directory)))
                     
                     ;; Only open each file once
                     (unless (member file files-opened)
                       (push file files-opened)
                       
                       ;; Open the file in a buffer
                       (with-current-buffer (find-file-noselect abs-path)
                         ;; Go to the line of the first match in this file
                         (goto-char (point-min))
                         (forward-line (1- line))
                         
                         ;; Add file to gptel context
                         (gptel-add (current-buffer))
                         (push file context-added))))))
               
               ;; Return summary of what was done
               (format "Searched for '%s' in %s.\nFound matches in %d files.\nOpened and added to context: %s"
                       pattern
                       (expand-file-name dir)
                       (length files-opened)
                       (mapconcat 'identity context-added ", "))))
 :description "Search files with ripgrep, open matching files, and add them to gptel context"
 :args (list '(:name "pattern"
               :type string
               :description "The search pattern to find in files")
             '(:name "dir"
               :type string
               :description "The directory to search in (default: project root)")
             '(:name "file-pattern"
               :type string
               :description "Optional file pattern to limit search (e.g., '*.el' or '*.org')"
               :optional t))
 :category "search")

;; Directory listing tool constrained to current projectile project
(gptel-make-tool
 :name "list_directory"
 :function (lambda (dir &optional recursive pattern)
             ;; Ensure we're in a projectile project
             (unless (projectile-project-p)
               (error "Not in a projectile project"))
             
             ;; Get project root and normalize paths
             (let* ((project-root (projectile-project-root))
                    (target-dir (expand-file-name (or dir ".") project-root))
                    (rel-path (file-relative-name target-dir project-root)))
               
               ;; Ensure the target directory is within the project
               (unless (string-prefix-p project-root target-dir)
                 (error "Error: Directory %s is outside the current project %s" dir project-root))
               
               ;; Ensure the directory exists
               (unless (file-directory-p target-dir)
                 (error "Error: %s is not a valid directory" dir))
               
               ;; Get directory contents
               (let ((files (if recursive
                                (directory-files-recursively target-dir (or pattern ".*"))
                              (directory-files target-dir t (or pattern ".*") t)))
                     (result-buffer (get-buffer-create "*directory-listing*")))
                 
                 ;; Create a formatted output in the result buffer
                 (with-current-buffer result-buffer
                   (erase-buffer)
                   (insert (format "Directory listing for: %s\n" rel-path))
                   (insert (format "Project root: %s\n\n" project-root))
                   
                   ;; Add mode information and format the output
                   (insert "Mode          Size               Modified             Name\n")
                   (insert "------------- ------------------ -------------------- ------------------------\n")
                   
                   ;; For each file, get and format details
                   (dolist (file files)
                     (let* ((attrs (file-attributes file))
                            (type (car attrs))
                            (mode-string (if (stringp type)
                                            "l" ; symbolic link
                                          (if (file-directory-p file)
                                              "d" ; directory
                                            "-"))) ; regular file
                            (size (file-attribute-size attrs))
                            (mod-time (format-time-string "%Y-%m-%d %H:%M:%S" (file-attribute-modification-time attrs)))
                            (name (if recursive
                                      (file-relative-name file project-root)
                                    (file-name-nondirectory file))))
                       
                       (insert (format "%s%-12s %18d %20s %s\n"
                                      mode-string
                                      (if (file-directory-p file) "directory" "file")
                                      size
                                      mod-time
                                      name))))
                   
                   ;; Add the buffer to gptel context
                   (gptel-add (current-buffer))
                   (display-buffer (current-buffer))
                   
                   ;; Return a summary with count of files found
                   (format "Listed %d items from directory '%s' in the current project. Results added to context."
                           (length files) rel-path)))))
 :description "List contents of a directory within the current projectile project"
 :args (list '(:name "dir"
               :type string
               :description "Relative directory path within the project (default: project root)")
             '(:name "recursive"
               :type boolean
               :description "Whether to list directories recursively"
               :optional t)
             '(:name "pattern"
               :type string
               :description "Optional file pattern to filter results (regex pattern)"
               :optional t))
 :category "filesystem")

;; File movement/renaming tool constrained to current projectile project
(gptel-make-tool
 :name "move_file"
 :function (lambda (source-path destination-path)
             ;; Ensure we're in a projectile project
             (unless (projectile-project-p)
               (error "Not in a projectile project"))
             
             ;; Get project root and normalize paths
             (let* ((project-root (projectile-project-root))
                    (source-full-path (expand-file-name source-path project-root))
                    (dest-full-path (expand-file-name destination-path project-root))
                    (source-rel-path (file-relative-name source-full-path project-root))
                    (dest-rel-path (file-relative-name dest-full-path project-root)))
               
               ;; Safety checks
               (unless (string-prefix-p project-root source-full-path)
                 (error "Error: Source path %s is outside the current project" source-path))
               
               (unless (string-prefix-p project-root dest-full-path)
                 (error "Error: Destination path %s is outside the current project" destination-path))
               
               ;; Check if source file exists
               (unless (file-exists-p source-full-path)
                 (error "Error: Source file %s does not exist" source-path))
               
               ;; Create destination directory if it doesn't exist
               (let ((dest-dir (file-name-directory dest-full-path)))
                 (when (and dest-dir (not (file-exists-p dest-dir)))
                   (make-directory dest-dir t)))
               
               ;; Perform the move/rename operation
               (rename-file source-full-path dest-full-path)
               
               ;; Update any open buffers
               (when-let ((buffer (find-buffer-visiting source-full-path)))
                 (with-current-buffer buffer
                   (set-visited-file-name dest-full-path nil t)))
               
               ;; Return success message
               (format "Successfully moved file from '%s' to '%s'" source-rel-path dest-rel-path)))
 :description "Move or rename a file within the current projectile project"
 :args (list '(:name "source-path"
               :type string
               :description "Relative path to the source file within the project")
             '(:name "destination-path"
               :type string
               :description "Relative path to the destination within the project"))
 :category "filesystem")

;; Make the tools available to gptel
(provide 'gptel-tools)
