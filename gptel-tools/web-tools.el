;;; gptel-tools-web.el --- Web interaction tools for gptel -*- lexical-binding: t; -*-

;;; Commentary:
;; Provides tools for web searches and other online interactions

;;; Code:
(require 'gptel)
(require 'url-util)

;; DuckDuckGo search tool using lynx
(gptel-make-tool
 :name "search_the_web"
 :function (lambda (query)
             ;; Log the query being made
             (let ((url (format "https://duckduckgo.com/html/?q=%s"
                                (url-hexify-string query)))
                   (buffer-name "*duckduckgo-results*")
                   (urls-found nil))
               (message "DuckDuckGo search url: %s" url)
               ;; Create a buffer for results
               (with-current-buffer (get-buffer-create buffer-name)
                 (erase-buffer)
                 (insert (format "DuckDuckGo search results for: %s\n\n" query))

                 ;; Use lynx to fetch the results and show links
                 (let ((lynx-cmd (format "lynx -dump \"%s\"" url)))
                   (call-process-shell-command lynx-cmd nil t)
                   
                   ;; Extract URLs from the lynx output
                   (goto-char (point-min))
                   (while (re-search-forward "^ *\\([0-9]+\\)\\.\\s-*\\(https?://[^\n]+\\)" nil t)
                     (push (match-string 2) urls-found))
                   
                   ;; Add the buffer to gptel context
                   (gptel-add (current-buffer))
                   (display-buffer (current-buffer))

                   ;; Return a summary with all found URLs
                   (if urls-found
                       (format "Search results for '%s':\n%s" 
                               query
                               (mapconcat 'identity (reverse urls-found) "\n"))
                     (format "Search results for '%s' (no URLs found)" query))))))
 :description "search the web for pages about aa topic"
 :args (list '(:name "query"
               :type string
               :description "the search query to for"))
 :category "web")

;; Tool to open a specific URL and add content to context
(gptel-make-tool
 :name "read_url"
 :function (lambda (url)
             (let ((buffer-name "*url-content*"))
               ;; Create a buffer for results
               (with-current-buffer (get-buffer-create buffer-name)
                 (erase-buffer)
                 (insert (format "Content from: %s\n\n" url))

                 ;; Use lynx to fetch the URL content
                 (let ((lynx-cmd (format "lynx -dump -nolist \"%s\"" url)))
                   (call-process-shell-command lynx-cmd nil t)

                   ;; Remove extra whitespace
                   (goto-char (point-min))
                   (while (re-search-forward "\\s-+" nil t)
                     (replace-match " "))

                   ;; Add the buffer to gptel context
                   (gptel-add (current-buffer))
                   (display-buffer (current-buffer))

                   ;; Return a summary
                   (format "Content from '%s' has been fetched and added to context." url)))))
 :description "read the contents of a url"
 :args (list '(:name "url"
               :type string
               :description "the URL to fetch content from"))
 :category "web")

(provide 'web-tools)
;;; gptel-tools-web.el ends here