# Interactive Tools for GPTel

This tool allows the LLM to interact with users in real-time, preventing guesswork and enabling more collaborative conversations.

## Inspiration

Based on the [interactive-mcp project](https://ttommyth.medium.com/stop-your-ai-assistant-from-guessing-introducing-interactive-mcp-b42ac6d9b0e2), these tools address the common problem where AI assistants make assumptions instead of asking for clarification.

## Available Tools

### 1. `ask_user_question`
Ask the user an open-ended question and get their text response.

**Parameters:**
- `question` (string): The question to ask the user
- `default_value` (string, optional): Default answer if user presses enter without typing

**Usage:** Use this instead of guessing when you need clarification or specific information from the user.

### 2. `ask_user_choice`
Ask the user to choose from multiple options with arrow key navigation.

**Parameters:**
- `question` (string): The question/prompt to show the user
- `choices` (string): Comma-separated list of choices for the user to select from
- `default_choice` (string, optional): Default choice if user doesn't select anything

**Usage:** Use this when you need the user to select from specific alternatives rather than guessing their preference.

### 3. `notify_user`
Send a notification message to the user.

**Parameters:**
- `message` (string): The notification message to send to the user
- `urgency` (string, optional): Urgency level: 'low', 'normal', or 'high' (default: 'normal')

**Usage:** Use this to inform users of progress, completion, or important information.

### 4. `confirm_user_action`
Ask the user to confirm an action with yes/no.

**Parameters:**
- `question` (string): The confirmation question to ask
- `default_yes` (boolean, optional): Whether 'yes' should be the default choice

**Usage:** Use this before performing potentially destructive or significant operations.

### 5. `get_user_preference`
Get user preference or configuration setting.

**Parameters:**
- `preference_name` (string): Descriptive name of what preference is being set
- `options` (string): Comma-separated list of available preference options
- `current_value` (string, optional): Current value of the preference, if any

**Usage:** Use this when you need to know user preferences for customization or configuration.

## Benefits

- **💰 Reduced API Calls**: Avoid wasting expensive API calls generating code based on guesswork
- **✅ Fewer Errors**: Clarification before action means less incorrect code and wasted time
- **⏱️ Faster Cycles**: Quick confirmations beat debugging wrong guesses
- **🎮 Better Collaboration**: Turns one-way instructions into a dialogue, keeping you in control

## Examples

### Before (AI guessing):
```
User: "Refactor this function"
AI: *Proceeds to rewrite half the file based on assumptions*
```

### After (AI asking for clarification):
```
User: "Refactor this function"
AI: Uses ask_user_choice to ask: "What type of refactoring would you like?"
Choices: "Extract methods, Optimize performance, Improve readability, Rename variables"
User selects: "Improve readability"
AI: *Makes targeted readability improvements*
```

## Installation

1. The tool is automatically loaded when you load `gptel-tools-index.el`
2. Make sure `gptel-use-tools` is set to `t`
3. The LLM can now use these interactive functions in conversations

## Error Handling

- All functions handle user cancellation (C-g) gracefully
- Invalid choices are validated and helpful error messages are provided
- Functions return appropriate error messages when parameters are malformed

## Integration with Emacs

- Uses native Emacs functions like `read-string` and `completing-read`
- Supports arrow key navigation for multiple choice questions
- Notifications appear in both the minibuffer and the *Messages* buffer
- High urgency notifications include audio alerts
