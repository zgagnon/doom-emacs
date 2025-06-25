;;; interactive-tools.el --- Interactive user input tools for gptel -*- lexical-binding: t; -*-

;; Copyright (C) 2024 Zell Liew

;; Author: Zell Liew
;; Keywords: gptel, tools, interaction, user-input
;; Version: 1.0

;;; Commentary:
;; This package provides interactive tools for gptel that allow the LLM to ask
;; questions and get user input in real-time. This prevents the AI from guessing
;; and enables more collaborative interactions.
;;
;; Inspired by the interactive-mcp project, this tool allows the LLM to:
;; - Ask open-ended questions and get text responses
;; - Present multiple choice questions with easy selection
;; - Send notifications to the user
;;
;; This addresses the common problem of LLMs making assumptions instead of
;; asking for clarification, leading to better results and fewer mistakes.

;;; Code:
(require 'gptel)
(require 'seq)

(defun gptel-ask-user-question (question &optional default-value)
  "Ask the user a QUESTION and return their text response.
QUESTION is the text prompt to show the user.
DEFAULT-VALUE is an optional default response if user presses enter without typing."
  (condition-case nil
      (let ((prompt (format "%s%s: " 
                           question 
                           (if (and default-value (not (string-empty-p default-value))) 
                               (format " (default: %s)" default-value) 
                             ""))))
        (let ((response (read-string prompt nil nil default-value)))
          (if (string-empty-p response)
              (or default-value "")
            response)))
    (quit "User cancelled input")))

(gptel-make-tool
 :function #'gptel-ask-user-question
 :name "ask_user_question"
 :description "Ask the user an open-ended question and get their text response. Use this instead of guessing when you need clarification or specific information from the user."
 :args (list '(:name "question"
               :type string
               :description "The question to ask the user")
             '(:name "default_value"
               :type string
               :description "Optional default answer if user presses enter without typing"))
 :category "user-interaction")

(defun gptel-ask-user-choice (question choices &optional default-choice)
  "Ask the user to choose from multiple CHOICES for a given QUESTION.
QUESTION is the prompt to show the user.
CHOICES is a comma-separated string of options to choose from.
DEFAULT-CHOICE is an optional default if provided."
  (condition-case nil
      (let* ((choice-list (mapcar #'string-trim (split-string choices ",")))
             (choice-list (seq-filter (lambda (s) (not (string-empty-p s))) choice-list)))
        (if (null choice-list)
            "Error: No valid choices provided"
          (let* ((prompt (format "%s (choices: %s)%s: " 
                                question 
                                (mapconcat #'identity choice-list ", ")
                                (if (and default-choice (not (string-empty-p default-choice)))
                                    (format " [default: %s]" default-choice)
                                  "")))
                 (selected (completing-read prompt choice-list nil t nil nil default-choice)))
            (if (string-empty-p selected)
                (or default-choice (car choice-list))
              selected))))
    (quit "User cancelled selection")))

(gptel-make-tool
 :function #'gptel-ask-user-choice
 :name "ask_user_choice"
 :description "Ask the user to choose from multiple options. Use this when you need the user to select from specific alternatives rather than guessing their preference."
 :args (list '(:name "question"
               :type string
               :description "The question to ask the user")
             '(:name "choices"
               :type string
               :description "Comma-separated list of choices for the user to select from")
             '(:name "default_choice"
               :type string
               :description "Optional default choice if user doesn't select anything"))
 :category "user-interaction")

(defun gptel-notify-user (message &optional urgency)
  "Send a notification MESSAGE to the user.
MESSAGE is the notification text to display.
URGENCY can be 'low', 'normal', or 'high' to indicate importance."
  (let ((urgency-level (or urgency "normal")))
    (cond
     ((string= urgency-level "high")
      (message "🚨 URGENT: %s" message)
      (ding))  ; Audio notification for high urgency
     ((string= urgency-level "low")
      (message "ℹ️  %s" message))
     (t
      (message "📋 %s" message)))
    
    ;; Also display in *Messages* buffer for persistence
    (with-current-buffer (get-buffer-create "*Messages*")
      (let ((inhibit-read-only t))
        (goto-char (point-max))
        (insert (format "[%s] GPTel Notification (%s): %s\n" 
                        (format-time-string "%H:%M:%S")
                        urgency-level 
                        message))))
    
    (format "Notification sent to user: %s" message)))

(gptel-make-tool
 :function #'gptel-notify-user
 :name "notify_user"
 :description "Send a notification message to the user. Use this to inform them of progress, completion, or important information."
 :args (list '(:name "message"
               :type string
               :description "The notification message to send to the user")
             '(:name "urgency"
               :type string
               :description "Urgency level: 'low', 'normal', or 'high' (default: 'normal')"))
 :category "user-interaction")

(defun gptel-confirm-user-action (question &optional default-yes)
  "Ask the user to confirm an action with a yes/no QUESTION.
QUESTION is the confirmation prompt.
DEFAULT-YES when non-nil makes 'yes' the default choice."
  (condition-case nil
      (let* ((default-text (if default-yes " [Y/n]" " [y/N]"))
             (prompt (format "%s%s: " question default-text))
             (response (read-string prompt)))
        (cond
         ((string-empty-p response)
          (if default-yes "yes" "no"))
         ((string-match-p "^[yY]" response)
          "yes")
         ((string-match-p "^[nN]" response)
          "no")
         (t
          ;; Invalid response, ask again with clarification
          (gptel-confirm-user-action 
           (format "%s (Please answer 'yes' or 'no')" question) 
           default-yes))))
    (quit "User cancelled confirmation")))

(gptel-make-tool
 :function #'gptel-confirm-user-action
 :name "confirm_user_action"
 :description "Ask the user to confirm an action with yes/no. Use this before performing potentially destructive or significant operations."
 :args (list '(:name "question"
               :type string
               :description "The confirmation question to ask")
             '(:name "default_yes"
               :type boolean
               :description "Whether 'yes' should be the default choice (true/false)"))
 :category "user-interaction")

(defun gptel-get-user-preference (preference-name options &optional current-value)
  "Get user preference for PREFERENCE-NAME from OPTIONS.
PREFERENCE-NAME is a descriptive name for what's being configured.
OPTIONS is a comma-separated string of available choices.
CURRENT-VALUE is the current setting if any."
  (let ((question (format "What would you like to set for %s?%s" 
                         preference-name
                         (if (and current-value (not (string-empty-p current-value)))
                             (format " (currently: %s)" current-value)
                           ""))))
    (gptel-ask-user-choice question options current-value)))

(gptel-make-tool
 :function #'gptel-get-user-preference
 :name "get_user_preference"
 :description "Get user preference or configuration setting. Use this when you need to know user preferences for customization or configuration."
 :args (list '(:name "preference_name"
               :type string
               :description "Descriptive name of what preference is being set")
             '(:name "options"
               :type string
               :description "Comma-separated list of available preference options")
             '(:name "current_value"
               :type string
               :description "Current value of the preference, if any"))
 :category "user-interaction")

(provide 'interactive-tools)
;;; interactive-tools.el ends here
