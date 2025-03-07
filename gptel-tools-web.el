;;; gptel-tools-web.el --- Web interaction tools for gptel -*- lexical-binding: t; -*-

;;; Commentary:
;; Provides tools for web searches and other online interactions

;;; Code:
(require 'gptel)
(require 'url-util)

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

;; Tool to open a specific URL using Firefox with enhanced JavaScript support
(gptel-make-tool
 :name "open_url"
 :function (lambda (url)
             (let* ((buffer-name "*url-content*")
                    (temp-file (make-temp-file "firefox-output-" nil ".txt"))
                    (is-macos (string-match-p "darwin" system-configuration))
                    (firefox-cmd
                     (if is-macos
                         ;; For macOS: use open -a firefox with arguments
                         (format "open -a firefox --args --headless --no-remote --disable-gpu --window-size=1280,1696 -jsscript 'setTimeout(function(){document.querySelectorAll(\"button\").forEach(b => { if(b.textContent.includes(\"I understand\") || b.textContent.includes(\"Continue\") || b.textContent.includes(\"Accept\")) b.click(); }); setTimeout(function() { const content = document.body.innerText; require(\"fs\").writeFileSync(\"%s\", content); }, 2000);}, 3000)' %s"
                                temp-file (shell-quote-argument url))
                       ;; For other systems: call firefox directly
                       (format "firefox --headless --no-remote --disable-gpu --window-size=1280,1696 -jsscript 'setTimeout(function(){document.querySelectorAll(\"button\").forEach(b => { if(b.textContent.includes(\"I understand\") || b.textContent.includes(\"Continue\") || b.textContent.includes(\"Accept\")) b.click(); }); setTimeout(function() { const content = document.body.innerText; require(\"fs\").writeFileSync(\"%s\", content); }, 2000);}, 3000)' %s"
                              temp-file (shell-quote-argument url)))))
               
               ;; Create a buffer for results
               (with-current-buffer (get-buffer-create buffer-name)
                 (erase-buffer)
                 (insert (format "Content from: %s\n\n" url))
                 
                 ;; Execute firefox command
                 (let ((result (shell-command-to-string firefox-cmd)))
                   ;; Wait for the file to be written
                   (sleep-for 5)
                   
                   ;; Check if the file was created and has content
                   (if (and (file-exists-p temp-file)
                            (> (file-attribute-size (file-attributes temp-file)) 0))
                       (progn
                         ;; Read content from temp file
                         (insert-file-contents temp-file)
                         ;; Add the buffer to gptel context
                         (gptel-add (current-buffer))
                         (display-buffer (current-buffer))
                         ;; Clean up temp file
                         (delete-file temp-file)
                         ;; Return success message
                         (format "Content from '%s' has been fetched using Firefox with JavaScript support and added to context." url))
                     
                     ;; If file creation failed, try a simpler approach with curl as fallback
                     (message "Firefox extraction failed. Falling back to curl.")
                     (erase-buffer)
                     (insert (format "Content from: %s (curl fallback)\n\n" url))
                     (let ((curl-cmd (format "curl -L -s \"%s\" -A \"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36\"" url)))
                       (call-process-shell-command curl-cmd nil t)
                       
                       ;; Basic HTML cleanup for readability
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
                       
                       ;; Return fallback message
                       (format "Content from '%s' has been fetched using curl fallback and added to context." url)))))))
 :description "opens a specified URL and adds the content to context using Firefox with JavaScript support"
 :args (list '(:name "url"
               :type string
               :description "the URL to fetch content from"))
 :category "web")

(provide 'gptel-tools-web)
;;; gptel-tools-web.el ends here
