#!/bin/bash

# Claude Code Notification hook
# This hook triggers when Claude is waiting for user input or needs permission

# Configuration
BOT_URL="${CLAUDE_NOTIFIER_URL:-http://localhost:8080/api/notify}"
CHAT_ID="${TELEGRAM_CHAT_ID}"

# Check if CHAT_ID is set
if [ -z "$CHAT_ID" ]; then
    echo "Warning: TELEGRAM_CHAT_ID is not set. Skipping notification." >&2
    exit 0
fi

# Read hook input from stdin
HOOK_INPUT=$(cat)

# Extract data from hook input
SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id // "unknown"')
NOTIFICATION_MESSAGE=$(echo "$HOOK_INPUT" | jq -r '.message // "Claude is waiting for input"')
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // ""')

# Get timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Initialize variables
LAST_CLAUDE_MESSAGE="N/A"

# Parse transcript to get last assistant message (Claude's question)
if [ -f "$TRANSCRIPT_PATH" ]; then
    # Get last assistant message (search backwards for role: assistant)
    LAST_CLAUDE_MESSAGE=$(tac "$TRANSCRIPT_PATH" | \
        jq -r 'select(.role == "assistant") |
               if .content | type == "array" then
                   .content[] | select(.type == "text") | .text
               else
                   .content // .text // ""
               end' | \
        head -1 | \
        cut -c1-200)

    # If empty, try alternative extraction
    if [ -z "$LAST_CLAUDE_MESSAGE" ] || [ "$LAST_CLAUDE_MESSAGE" = "null" ]; then
        LAST_CLAUDE_MESSAGE=$(tac "$TRANSCRIPT_PATH" | \
            jq -r 'select(.role == "assistant") | .content // ""' | \
            head -1 | \
            cut -c1-200)
    fi
fi

# Truncate message if too long
if [ ${#LAST_CLAUDE_MESSAGE} -gt 200 ]; then
    LAST_CLAUDE_MESSAGE="${LAST_CLAUDE_MESSAGE:0:200}..."
fi

# Handle empty message
if [ -z "$LAST_CLAUDE_MESSAGE" ] || [ "$LAST_CLAUDE_MESSAGE" = "null" ]; then
    LAST_CLAUDE_MESSAGE="$NOTIFICATION_MESSAGE"
fi

# Create notification message
MESSAGE="⏸️ Claude Code Waiting for Input

❓ Message: $LAST_CLAUDE_MESSAGE

🆔 Session: $SESSION_ID
⏰ Time: $TIMESTAMP"

# Use jq to create properly formatted JSON payload
JSON_PAYLOAD=$(jq -n \
  --arg chatId "$CHAT_ID" \
  --arg message "$MESSAGE" \
  '{chatId: $chatId, message: $message}')

# Send notification to the bot
RESPONSE=$(curl -s -X POST "$BOT_URL" \
    -H "Content-Type: application/json" \
    -d "$JSON_PAYLOAD" \
    --connect-timeout 5 \
    --max-time 10)

# Check if the request was successful
if [ $? -eq 0 ]; then
    echo "Notification sent successfully for session: $SESSION_ID" >&2
else
    echo "Failed to send notification for session: $SESSION_ID" >&2
    exit 1
fi
