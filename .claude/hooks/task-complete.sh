#!/bin/bash

# Claude Code Stop hook for task completion notification
# This hook receives JSON input via stdin when Claude finishes responding

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
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // ""')

# Get timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Initialize summary variables
LAST_USER_MESSAGE="N/A"
TOOL_COUNT=0
MESSAGE_COUNT=0

# Parse transcript if available
if [ -f "$TRANSCRIPT_PATH" ]; then
    # Count total messages
    MESSAGE_COUNT=$(wc -l < "$TRANSCRIPT_PATH" | tr -d ' ')

    # Get last user message (search backwards for role: user)
    LAST_USER_MESSAGE=$(tac "$TRANSCRIPT_PATH" | \
        jq -r 'select(.role == "user") | .content // .text // ""' | \
        head -1 | \
        cut -c1-120)

    # Count tool uses
    TOOL_COUNT=$(grep -c '"type".*"tool_use"' "$TRANSCRIPT_PATH" 2>/dev/null || echo "0")

    # If last user message is empty, try alternative extraction
    if [ -z "$LAST_USER_MESSAGE" ] || [ "$LAST_USER_MESSAGE" = "null" ]; then
        LAST_USER_MESSAGE=$(tac "$TRANSCRIPT_PATH" | \
            jq -r 'select(.role == "user") | .content[0].text // ""' | \
            head -1 | \
            cut -c1-120)
    fi
fi

# Truncate last message if too long
if [ ${#LAST_USER_MESSAGE} -gt 120 ]; then
    LAST_USER_MESSAGE="${LAST_USER_MESSAGE:0:120}..."
fi

# Handle empty message
if [ -z "$LAST_USER_MESSAGE" ]; then
    LAST_USER_MESSAGE="No user message found"
fi

# Create notification message
MESSAGE="✅ Claude Code Session Completed

📝 Request: $LAST_USER_MESSAGE

🔧 Tools used: $TOOL_COUNT
💬 Messages: $MESSAGE_COUNT
⏰ Completed: $TIMESTAMP"

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
