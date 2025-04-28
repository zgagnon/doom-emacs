# Step-by-Step Guide to Creating New GPTel Tools

This guide provides simple, straightforward instructions for creating custom tools for GPTel in Emacs. These instructions are designed to be easy to follow for any LLM.

## Basic Steps

1. **Create a new Elisp file** with a `.el` extension (example: `my-tool.el`)

2. **Add the required headers and imports**:
   ```elisp
   ;;; my-tool.el --- Description of your tool -*- lexical-binding: t; -*-

   ;; Copyright (C) YEAR YOUR-NAME

   (require 'gptel)
   ```

3. **Define your tool function**:
   ```elisp
   (defun gptel-my-tool-function (parameter1 parameter2)
     "Function that implements your tool.
   PARAMETER1 is the first input needed by the tool.
   PARAMETER2 is the second input needed by the tool."
     ;; Your function implementation goes here
     (let ((result (format "Processed %s and %s" parameter1 parameter2)))
       result))
   ```

4. **Register your tool** using either the new or old method:

   **New method (preferred)**:
   ```elisp
   (gptel-make-tool
    :function #'gptel-my-tool-function
    :name "my_tool_name"
    :description "A clear description of what this tool does"
    :args (list '(:name "parameter1"
                  :type string
                  :description "Description of parameter1")
                '(:name "parameter2"
                  :type string
                  :description "Description of parameter2"))
    :category "your-category")
   ```

   **Old method (for compatibility)**:
   ```elisp
   (gptel-make-function "my_tool_name"
                        #'gptel-my-tool-function
                        "A clear description of what this tool does"
                        '((:name "parameter1" :type "string" :description "Description of parameter1")
                          (:name "parameter2" :type "string" :description "Description of parameter2")))
   ```

5. **Provide the feature** at the end of your file:
   ```elisp
   (provide 'my-tool)
   ;;; my-tool.el ends here
   ```

6. **Register your tool** in the index file at `/path/to/gptel-tools/gptel-tools-index.el`:
   ```elisp
   (require 'my-tool)
   ```

## Important Requirements

- **Tool names** must use snake_case (e.g., "read_file", not "readFile")
- **Parameter names** must also use snake_case
- **Valid parameter types** include: 
  - string
  - number
  - boolean
  - array
  - object

## Testing Your Tool

1. Load your tool by evaluating the buffer or restarting Emacs
2. Make sure tool usage is enabled: `(setq gptel-use-tools t)`
3. Start a gptel conversation and ask the AI to use your tool

## Example of a Complete Simple Tool

```elisp
;;; hello-world-tool.el --- A simple hello world tool -*- lexical-binding: t; -*-

;; Copyright (C) 2023 Your Name

(require 'gptel)

(defun gptel-hello-world (name)
  "Say hello to NAME."
  (format "Hello, %s!" name))

(gptel-make-tool
 :function #'gptel-hello-world
 :name "hello_world"
 :description "A simple tool that says hello to someone"
 :args (list '(:name "name"
               :type string
               :description "The name of the person to greet"))
 :category "examples")

(provide 'hello-world-tool)
;;; hello-world-tool.el ends here
```

Remember to handle errors gracefully in your tool function and return helpful error messages when needed.
Last edited: 2025-04-28
