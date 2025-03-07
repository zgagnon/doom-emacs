;;; gptel-mcp.el --- Integration between GPTel and MCP file servers -*- lexical-binding: t; -*-

;; Copyright (C) 2024

;; Author: GPTel Assistant
;; Keywords: comm, tools, gptel

;; This file is not part of GNU Emacs.

;;; Commentary:

;; This package provides integration between GPTel and MCP (Mud Client Protocol) file servers.
;; It enables GPTel to request and receive file contents from MCP-compliant servers,
;; allowing for AI assistance with remote MCP-shared files.

;; Requires the 'mcp' package (https://github.com/lizqwerscott/mcp.el)
;; and 'gptel' package to be installed.

;;; Code:

(require 'mcp)
(require 'gptel)

(defgroup gptel-mcp nil
  "GPTel integration with MCP file servers."
  :group 'gptel
  :prefix "gptel-mcp-")

(defcustom gptel-mcp-default-server nil
  "Default MCP server hostname."
  :type 'string
  :group 'gptel-mcp)

(defcustom gptel-mcp-default-port 7777
  "Default MCP server port."
  :type 'integer
  :group 'gptel-mcp)

(defvar gptel-mcp-connection nil
  "Active MCP connection for GPTel integration.")

(defvar gptel-mcp-file-responses (make-hash-table :test 'equal)
  "Hash table to store file responses from MCP server.")

(defun gptel-mcp-connect (host port)
  "Connect to MCP server at HOST:PORT."
  (interactive
   (list (read-string "MCP Server: " gptel-mcp-default-server)
         (read-number "Port: " gptel-mcp-default-port)))
  
  (let ((conn (mcp-connect host port)))
    (if conn
        (progn
          (setq gptel-mcp-connection conn)
          (message "Connected to MCP server %s:%d" host port)
          ;; Register a message handler for file responses
          (mcp-register-handler conn "mcp-file-package"
                               #'gptel-mcp-file-handler)
          conn)
      (message "Failed to connect to MCP server")
      nil)))

(defun gptel-mcp-file-handler (conn package-name message-name message)
  "Handle MCP file responses.
CONN is the connection, PACKAGE-NAME is the MCP package name,
MESSAGE-NAME is the message type, and MESSAGE is the content."
  (when (and (string= package-name "mcp-file-package")
             (string= message-name "file-content"))
    (let ((file-path (alist-get 'path message))
          (content (alist-get 'content message)))
      (when (and file-path content)
        (puthash file-path content gptel-mcp-file-responses)
        (message "Received file: %s" file-path)))))

(defun gptel-mcp-request-file (file-path &optional timeout)
  "Request a file at FILE-PATH from the MCP server.
Optional TIMEOUT in seconds, defaults to 5."
  (unless gptel-mcp-connection
    (error "No active MCP connection. Use M-x gptel-mcp-connect"))
  
  (let ((timeout (or timeout 5)))
    ;; Clear any previous response for this file
    (remhash file-path gptel-mcp-file-responses)
    
    ;; Send MCP request for the file
    (mcp-send-message gptel-mcp-connection
                     "mcp-file-package"
                     "get-file"
                     `((path . ,file-path)))
    
    ;; Wait for response with timeout
    (with-timeout (timeout nil)
      (while (not (gethash file-path gptel-mcp-file-responses))
        (sit-for 0.1)))
    
    ;; Return the file content or nil if timeout
    (gethash file-path gptel-mcp-file-responses)))

;; Register GPTel tool for MCP file fetching
(gptel-define-tool gptel-mcp-fetch
  '(:name "fetch_mcp_file"
    :description "Fetch a file from an MCP server"
    :parameters (:type "object"
                 :properties ((file-path :type "string"
                                       :description "Path to the file on the MCP server"))
                 :required ("file-path")))
  (lambda (kwargs callback)
    (let* ((file-path (alist-get 'file-path kwargs))
           (content (gptel-mcp-request-file file-path)))
      (if content
          (funcall callback 
                  `((status . "success")
                    (file-path . ,file-path)
                    (content . ,content)))
        (funcall callback 
                `((status . "error")
                  (message . ,(format "Failed to fetch file: %s" file-path))))))))

(defun gptel-mcp-register-tools ()
  "Register the MCP tools with GPTel."
  (gptel-tool-register
   :name 'gptel-mcp-fetch
   :tool gptel-mcp-fetch))

;; Optionally auto-register tools when loaded
(gptel-mcp-register-tools)

(provide 'gptel-mcp)
;;; gptel-mcp.el ends here
