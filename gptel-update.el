;; Updated GPTel configuration 
;; To be added to the GPTel section in config.org

(after! gptel
  ;; Set a default system prompt that applies to all gptel interactions
  (setq gptel-default-system-prompt
        "You are a programming agent inside an emacs instance. When requested to perform an action, begin by formulating a plan. Use any tools needed to in order to plan well. Present the plan and wait for confirmation. When executing a plan, use all tools needed to accomplish the task. Respond concisely, and be careful about your work.")
  
  ;; Ensure tools are enabled
  (setq gptel-use-tools t)
  
  ;; Always ask for confirmation before executing tool calls
  (setq gptel-confirm-tool-calls 'ask)
  
  ;; Ask whether to include tool results in the response
  (setq gptel-include-tool-results 'ask))
