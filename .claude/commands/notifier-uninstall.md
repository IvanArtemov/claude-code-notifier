# Uninstall Claude Code Telegram Notifier

You are helping the user uninstall the Claude Code Telegram Notifier bot. This will remove hooks, stop the service, and optionally clean up configuration files.

⚠️ **WARNING**: This action will remove the notifier hooks and stop the service. The user will no longer receive Telegram notifications from Claude Code.

## Step 1: Confirm Uninstallation

Ask the user to confirm:

```
⚠️  You are about to uninstall Claude Code Telegram Notifier.

This will:
• Stop the running service
• Remove Claude Code hooks from ~/.claude/
• Optionally remove configuration files
• Optionally remove the entire project

You will no longer receive Telegram notifications.

Are you sure you want to proceed? (yes/no)
```

If the user says no or is unsure, exit gracefully.

## Step 2: Stop the Service

First, stop any running instances:

```
Stopping the notifier service...
```

Use the logic from `/notifier-stop`:

```bash
# Find and stop processes
PIDS=$(ps aux | grep -E "[g]radlew bootRun|[C]laudeNotifierApplication" | awk '{print $2}')

if [ -n "$PIDS" ]; then
  for PID in $PIDS; do
    kill $PID
    echo "Stopped process: $PID"
  done
  sleep 2
fi

# Verify stopped
if ! curl -s http://localhost:8080/api/health > /dev/null 2>&1; then
  echo "✅ Service stopped successfully"
else
  echo "⚠️  Service may still be running"
fi
```

## Step 3: Create Backup

Ask: "Would you like to create a backup of your configuration before removing it?"

If yes:

```bash
BACKUP_DIR=~/.claude/backups/notifier-$(date +%Y%m%d_%H%M%S)
mkdir -p "$BACKUP_DIR"

# Backup global settings
if [ -f ~/.claude/settings.json ]; then
  cp ~/.claude/settings.json "$BACKUP_DIR/settings.json.backup"
  echo "✅ Backed up: ~/.claude/settings.json"
fi

# Backup hooks
if [ -f ~/.claude/hooks/task-complete.sh ]; then
  cp ~/.claude/hooks/task-complete.sh "$BACKUP_DIR/"
  echo "✅ Backed up: task-complete.sh"
fi

if [ -f ~/.claude/hooks/notification.sh ]; then
  cp ~/.claude/hooks/notification.sh "$BACKUP_DIR/"
  echo "✅ Backed up: notification.sh"
fi

echo ""
echo "📦 Backup saved to: $BACKUP_DIR"
```

## Step 4: Remove Global Hooks

Remove hooks from `~/.claude/settings.json`:

```
Removing Claude Code hooks from global configuration...
```

```bash
if [ -f ~/.claude/settings.json ]; then
  # Create a temporary file without the notifier hooks
  jq '
    # Remove Stop and Notification hooks that point to our scripts
    if .hooks.Stop then
      .hooks.Stop |= map(select(
        .hooks[]?.command | test("task-complete.sh") | not
      ))
    end |
    if .hooks.Notification then
      .hooks.Notification |= map(select(
        .hooks[]?.command | test("notification.sh") | not
      ))
    end |
    # Remove empty hook arrays
    if .hooks.Stop == [] then .hooks.Stop = null end |
    if .hooks.Notification == [] then .hooks.Notification = null end |
    # Remove env variables
    if .env then
      .env |= del(.TELEGRAM_CHAT_ID, .CLAUDE_NOTIFIER_URL)
    end |
    # Remove env object if empty
    if .env == {} then .env = null end |
    # Remove hooks object if empty
    if .hooks == {} or .hooks == {"Stop": null, "Notification": null} then
      .hooks = null
    end
  ' ~/.claude/settings.json > ~/.claude/settings.json.tmp

  mv ~/.claude/settings.json.tmp ~/.claude/settings.json
  echo "✅ Removed hooks from ~/.claude/settings.json"
else
  echo "ℹ️  Global settings file not found (already removed?)"
fi
```

## Step 5: Remove Hook Scripts

Remove the hook script files:

```bash
# Remove task-complete.sh
if [ -f ~/.claude/hooks/task-complete.sh ]; then
  rm ~/.claude/hooks/task-complete.sh
  echo "✅ Removed: ~/.claude/hooks/task-complete.sh"
fi

# Remove notification.sh
if [ -f ~/.claude/hooks/notification.sh ]; then
  rm ~/.claude/hooks/notification.sh
  echo "✅ Removed: ~/.claude/hooks/notification.sh"
fi

# Remove hooks directory if empty
if [ -d ~/.claude/hooks ] && [ -z "$(ls -A ~/.claude/hooks)" ]; then
  rmdir ~/.claude/hooks
  echo "✅ Removed empty hooks directory"
fi
```

## Step 6: Clean Up Project Files (Optional)

Ask: "Would you like to remove local configuration and build files?"

If yes:

```bash
# Remove application-local.yml
if [ -f src/main/resources/application-local.yml ]; then
  rm src/main/resources/application-local.yml
  echo "✅ Removed: application-local.yml"
fi

# Remove log files
if [ -f notifier.log ]; then
  rm notifier.log*
  echo "✅ Removed: log files"
fi

# Remove PID file
if [ -f notifier.pid ]; then
  rm notifier.pid
  echo "✅ Removed: PID file"
fi

# Ask about build directory
echo ""
read -p "Remove build directory? (yes/no): " REMOVE_BUILD
if [ "$REMOVE_BUILD" = "yes" ]; then
  rm -rf build/
  echo "✅ Removed: build directory"
fi
```

## Step 7: Remove Entire Project (Optional)

⚠️ **DANGEROUS OPTION**

Ask: "Would you like to remove the ENTIRE project directory? This cannot be undone!"

If yes, ask for double confirmation:

```
⚠️  WARNING: This will permanently delete the entire ClaudeNotifier project!

Type 'DELETE PROJECT' to confirm:
```

Only if they type exactly "DELETE PROJECT":

```bash
PROJECT_DIR=$(pwd)
cd ..
rm -rf "$PROJECT_DIR"
echo "✅ Project directory removed: $PROJECT_DIR"
echo ""
echo "The ClaudeNotifier project has been completely removed from your system."
exit 0
```

## Step 8: Verification

Verify that everything was removed:

```bash
echo ""
echo "🔍 Verifying uninstallation..."

# Check service
if curl -s http://localhost:8080/api/health > /dev/null 2>&1; then
  echo "⚠️  Service is still running on port 8080"
else
  echo "✅ Service is not running"
fi

# Check global hooks
if grep -q "task-complete.sh\|notification.sh" ~/.claude/settings.json 2>/dev/null; then
  echo "⚠️  Hooks still found in ~/.claude/settings.json"
else
  echo "✅ No hooks found in global settings"
fi

# Check hook files
if [ -f ~/.claude/hooks/task-complete.sh ] || [ -f ~/.claude/hooks/notification.sh ]; then
  echo "⚠️  Hook files still exist in ~/.claude/hooks/"
else
  echo "✅ Hook files removed"
fi
```

## Step 9: Final Summary

Provide a summary of what was removed:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ CLAUDE CODE TELEGRAM NOTIFIER - UNINSTALLED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The following has been removed:
✅ Notifier service (stopped)
✅ Global Claude Code hooks
✅ Hook scripts from ~/.claude/hooks/
[✅ Local configuration files]
[✅ Build directory]
[✅ Log files]

📦 Backup location: [BACKUP_DIR]

You will no longer receive Telegram notifications from Claude Code.

To reinstall:
1. Navigate to the ClaudeNotifier project
2. Run: /notifier-setup

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Additional Notes

Ask: "Would you like to keep the Telegram bot active for future use?"

Explain:
- The bot in Telegram is still active
- They can delete it via @BotFather if desired
- Or keep it for future reinstallation

If they want to delete the bot:
```
To delete your Telegram bot:
1. Open @BotFather in Telegram
2. Send: /deletebot
3. Select your bot
4. Confirm deletion
```

---

**Important**:
- Always create backups before removing files
- Require explicit confirmation for destructive actions
- Provide clear summary of what was removed
- Offer restoration instructions if they change their mind
