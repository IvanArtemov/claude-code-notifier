# Test Claude Code Telegram Notifier

You are helping the user test the Claude Code Telegram Notifier bot by sending a test notification.

## Step 1: Verify Service is Running

First, check if the notifier service is running:

```bash
curl -s -w "\n%{http_code}" http://localhost:8080/api/health --connect-timeout 2
```

If the service is not running (connection refused, timeout, or non-200 response):
- Inform the user: "The notifier service is not running. Please start it first."
- Suggest: "Run `/notifier-start` to start the service."
- Exit

## Step 2: Get Chat ID

Check if Chat ID is configured:

```bash
# Try to get from global Claude settings
if [ -f ~/.claude/settings.json ]; then
  CHAT_ID=$(jq -r '.env.TELEGRAM_CHAT_ID // empty' ~/.claude/settings.json 2>/dev/null)
fi

# If not found, try project settings
if [ -z "$CHAT_ID" ] && [ -f .claude/settings.json ]; then
  CHAT_ID=$(jq -r '.env.TELEGRAM_CHAT_ID // empty' .claude/settings.json 2>/dev/null)
fi
```

If Chat ID is not found or empty:
- Ask the user: "I couldn't find your Telegram Chat ID in the configuration. Please provide your Chat ID:"
- Wait for user input
- Use the provided Chat ID for the test

If Chat ID is found:
- Show (masked): "Using Chat ID: ${CHAT_ID:0:3}***${CHAT_ID: -3}"
- Ask: "Is this correct? (yes/no)"
- If no, ask for the correct Chat ID

## Step 3: Prepare Test Message

Create a test notification message:

```json
{
  "chatId": "[CHAT_ID]",
  "message": "🧪 Test Notification from Claude Code\n\n✅ Your Telegram notifier is working correctly!\n\n⏰ Test sent at: [TIMESTAMP]\n\nYou will receive notifications when:\n• Claude Code finishes a session (Stop hook)\n• Claude Code is waiting for your input (Notification hook)\n\n🤖 Claude Code Telegram Notifier"
}
```

Show the user the message that will be sent (with masked Chat ID).

## Step 4: Send Test Notification

Ask: "Ready to send a test notification to your Telegram?"

If yes:

```bash
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST http://localhost:8080/api/notify \
  -H "Content-Type: application/json" \
  -d "{
    \"chatId\": \"$CHAT_ID\",
    \"message\": \"🧪 Test Notification from Claude Code\n\n✅ Your Telegram notifier is working correctly!\n\n⏰ Test sent at: $TIMESTAMP\n\nYou will receive notifications when:\n• Claude Code finishes a session (Stop hook)\n• Claude Code is waiting for your input (Notification hook)\n\n🤖 Claude Code Telegram Notifier\"
  }" \
  --connect-timeout 5 \
  --max-time 10)

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | sed '$d')
```

## Step 5: Verify Response

Parse the HTTP response:

### Success (200 OK):
```bash
if [ "$HTTP_CODE" = "200" ]; then
  # Parse JSON response
  SUCCESS=$(echo "$BODY" | jq -r '.success // false')

  if [ "$SUCCESS" = "true" ]; then
    echo "✅ Test notification sent successfully!"
  else
    ERROR_MSG=$(echo "$BODY" | jq -r '.message // "Unknown error"')
    echo "❌ Failed to send notification: $ERROR_MSG"
  fi
fi
```

### Failure (non-200):
```bash
if [ "$HTTP_CODE" != "200" ]; then
  echo "❌ HTTP Error $HTTP_CODE"
  echo "Response: $BODY"
fi
```

## Step 6: User Verification

After sending, ask the user to verify:

```
📱 Please check your Telegram app!

Open your bot: @[BOT_USERNAME]

Did you receive the test notification?
```

Wait for user confirmation:
- **Yes, received**: ✅ Great! The notifier is working correctly.
- **No, didn't receive**: ⚠️ Let's troubleshoot...

## Step 7: Troubleshooting (if not received)

If the user didn't receive the notification:

### Check 1: Verify Chat ID
```
Let's verify your Chat ID is correct.

1. Open your Telegram bot
2. Send /start command
3. The bot will reply with your Chat ID
4. Does it match: [CURRENT_CHAT_ID]?
```

If Chat ID is wrong, update the configuration.

### Check 2: Check Bot Status
```bash
# Verify bot is responsive
curl -s http://localhost:8080/api/health
```

### Check 3: Check Logs
```bash
# If log file exists
if [ -f notifier.log ]; then
  echo "Recent log entries:"
  tail -20 notifier.log | grep -i "notification\|error\|telegram"
fi
```

### Check 4: Bot Token Validity
Ask: "Have you verified your bot token is correct in the application-local.yml file?"

Suggest: "You can check by looking for errors in the logs when the bot starts."

### Common Issues:

1. **Wrong Chat ID**:
   - "Get your correct Chat ID by sending /start to your bot"
   - "Update ~/.claude/settings.json with the correct ID"

2. **Invalid Bot Token**:
   - "Verify your bot token in src/main/resources/application-local.yml"
   - "Get a new token from @BotFather if needed"

3. **Bot not started**:
   - "Check if the bot initialized successfully in the logs"
   - "Look for 'Telegram bot registered successfully!' message"

4. **Network/Firewall issues**:
   - "Check if you have internet connection"
   - "Verify no firewall is blocking Telegram API"

## Step 8: Success Confirmation

If everything works:

```
🎉 Success! Your Telegram notifier is fully operational!

Next time Claude Code:
• Finishes responding → You'll get a notification
• Waits for input (60+ sec) → You'll get a notification

All notifications will be sent to your Telegram bot.

Commands:
/notifier-status - Check service status
/notifier-stop - Stop the service
/notifier-start - Start the service

Enjoy your notifications! 🚀
```

---

**Important**:
- Always mask sensitive information (Chat ID, tokens) in output
- Be patient and helpful during troubleshooting
- Provide clear next steps if the test fails