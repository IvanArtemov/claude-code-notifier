# Setup Claude Code Telegram Notifier

You are helping the user set up the Claude Code Telegram Notifier bot. This is an interactive installation process that will configure and run a Spring Boot application with Telegram bot integration.

## Prerequisites Check

First, check the following:

1. **Java Version**: Run `java -version` to verify Java 21 is installed
2. **Gradle**: Check that `./gradlew --version` works
3. **Telegram Bot**: Ask if the user has already created a bot via @BotFather

If any prerequisite is missing, provide instructions on how to install it.

## Step 1: Collect Telegram Bot Information

Ask the user for the following information:

1. **Telegram Bot Token**:
   - Ask: "Please provide your Telegram Bot Token (from @BotFather)"
   - If they don't have one, instruct them:
     - Open Telegram and find @BotFather
     - Send `/newbot` command
     - Follow instructions to create a bot
     - Copy the token provided

2. **Telegram Bot Username**:
   - Ask: "Please provide your bot's username (e.g., MyNotifierBot)"

3. **Telegram Chat ID** (Optional at this stage):
   - Ask: "Do you know your Telegram Chat ID? (You can get it later via /start command)"
   - If yes, ask them to provide it
   - If no, explain they'll get it after starting the bot

## Step 2: Create Configuration File

Explain to the user:
"I will create a local configuration file `src/main/resources/application-local.yml` with your bot credentials. This file will be ignored by git for security."

Create the file with the following content:
```yaml
telegram:
  bot:
    username: [USER_PROVIDED_USERNAME]
    token: [USER_PROVIDED_TOKEN]

server:
  port: 8080

logging:
  level:
    org.telegram: INFO
```

Also ensure `.gitignore` includes:
```
/src/main/resources/application-local.yml
```

Show the user what was created (without showing the full token - mask it).

## Step 3: Build the Application

Explain: "I will now build the Spring Boot application using Gradle. This may take a few minutes."

Run: `./gradlew build`

Show the build progress and result. If build fails, help debug the issue.

## Step 4: Start the Application

Ask: "Would you like me to start the Telegram bot application now?"

If yes:
1. Explain: "I'll start the application in the background. You can check logs in the console."
2. Run: `./gradlew bootRun` (in background if possible, or instruct user to run it in a separate terminal)
3. Wait a few seconds and check if it started: `curl -s http://localhost:8080/api/health`
4. Show the startup logs

## Step 5: Get Chat ID (if not provided earlier)

If the user didn't provide Chat ID:

1. Instruct the user:
   - "Open Telegram and search for your bot: @[BOT_USERNAME]"
   - "Send the `/start` command to your bot"
   - "The bot will reply with your Chat ID"
   - "Please provide the Chat ID you received"

2. Wait for the user to provide the Chat ID

## Step 6: Install Global Claude Code Hooks

Explain: "I will now install hooks in your global Claude Code configuration (~/.claude/). This will enable notifications for ALL your Claude Code sessions."

Ask: "Do you want to install hooks globally (recommended) or keep them project-specific?"

### If Global Installation:

1. Check if `~/.claude/settings.json` exists
2. Create backup if it exists: `cp ~/.claude/settings.json ~/.claude/settings.json.backup`
3. Copy hook scripts:
   ```bash
   mkdir -p ~/.claude/hooks
   cp .claude/hooks/notification.sh ~/.claude/hooks/
   cp .claude/hooks/task-complete.sh ~/.claude/hooks/
   chmod +x ~/.claude/hooks/*.sh
   ```
4. Update `~/.claude/settings.json` to include:
   ```json
   {
     "hooks": {
       "Stop": [{
         "hooks": [{
           "type": "command",
           "command": "~/.claude/hooks/task-complete.sh"
         }]
       }],
       "Notification": [{
         "hooks": [{
           "type": "command",
           "command": "~/.claude/hooks/notification.sh"
         }]
       }]
     },
     "env": {
       "TELEGRAM_CHAT_ID": "[USER_CHAT_ID]",
       "CLAUDE_NOTIFIER_URL": "http://localhost:8080/api/notify"
     }
   }
   ```

Show the user what was added to their global configuration.

## Step 7: Test the Setup

Ask: "Would you like me to send a test notification to verify everything works?"

If yes:
1. Send a test notification:
   ```bash
   curl -X POST http://localhost:8080/api/notify \
     -H "Content-Type: application/json" \
     -d '{"chatId": "[USER_CHAT_ID]", "message": "✅ Claude Code Notifier setup complete! You will now receive notifications when Claude finishes tasks or needs your input."}'
   ```
2. Ask the user to check their Telegram and confirm they received the message

## Step 8: Final Instructions

Provide the user with:

### ✅ Setup Complete!

Your Claude Code Telegram Notifier is now installed and running.

**What happens next:**
- When Claude finishes responding → You get a notification with session summary
- When Claude waits for input (60+ seconds) → You get a notification
- All notifications are sent to your Telegram: @[BOT_USERNAME]

**Useful Commands:**
- `/notifier-status` - Check if the bot is running
- `/notifier-stop` - Stop the bot service
- `/notifier-start` - Start the bot service
- `/notifier-test` - Send a test notification
- `/notifier-uninstall` - Remove hooks and stop service

**How to keep the bot running:**
The bot is currently running in this terminal session. To run it permanently:
1. Stop the current process (Ctrl+C)
2. Run: `nohup ./gradlew bootRun > notifier.log 2>&1 &`
3. Or use: `/notifier-start` command

**Logs location:** Check `notifier.log` or console output

**Next time you start your computer:** Run `/notifier-start` or `./gradlew bootRun`

---

## Important Notes

- Always ask for permission before executing commands
- Mask sensitive information (tokens, chat IDs) in output
- If any step fails, help the user debug before proceeding
- Be encouraging and helpful throughout the process
- After each major step, confirm it succeeded before moving to the next