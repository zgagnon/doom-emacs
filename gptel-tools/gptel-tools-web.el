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

;; Tool to open a specific URL and add content to context
(gptel-make-tool
 :name "open_url"
 :function (lambda (url)
             (let ((buffer-name "*url-content*"))
               ;; Create a buffer for results
               (with-current-buffer (get-buffer-create buffer-name)
                 (erase-buffer)
                 (insert (format "Content from: %s\n\n" url))

                 ;; Use curl to fetch the URL content
                 (let ((curl-cmd (format "curl -s \"%s\" -A \"Mozilla/5.0\"" url)))
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

                   ;; Return a summary
                   (format "Content from '%s' has been fetched and added to context." url)))))
 :description "opens a specified URL and adds the content to context"
 :args (list '(:name "url"
               :type string
               :description "the URL to fetch content from"))
 :category "web")

(provide 'gptel-tools-web)
;;; gptel-tools-web.el ends here
