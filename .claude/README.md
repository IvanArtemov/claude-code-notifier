# Claude Code Configuration

This directory contains configuration files for Claude Code integration.

## Files Overview

### 📁 Configuration Files

#### `settings.json` (Public)
Project-level configuration that is committed to git. Contains:
- Hook definitions (Stop, Notification)
- Placeholder for `TELEGRAM_CHAT_ID`
- Default `CLAUDE_NOTIFIER_URL`

**⚠️ Do NOT put your personal Chat ID here!** This file is public and will be in the repository.

#### `settings.local.json` (Private, Gitignored)
Your personal configuration that overrides `settings.json`. Contains:
- Your actual `TELEGRAM_CHAT_ID`

This file is **gitignored** and stays only on your machine.

**To create:**
```bash
cp settings.local.json.example settings.local.json
```

Then edit and replace `YOUR_TELEGRAM_CHAT_ID` with your actual Chat ID.

#### `settings.local.json.example` (Public)
Template for creating your local configuration. Shows the structure but contains placeholders.

### 📁 Hooks Directory

#### `hooks/task-complete.sh`
Stop hook that triggers when Claude Code finishes responding. Sends a notification with:
- Last user request
- Number of tools used
- Total messages in session
- Completion timestamp

#### `hooks/notification.sh`
Notification hook that triggers when Claude Code waits for input (60+ seconds). Sends a notification with:
- Last Claude message/question
- Session ID
- Timestamp

### 📁 Commands Directory

Contains slash commands for managing the notifier:
- `/notifier-setup` - Complete setup wizard
- `/notifier-start` - Start the service
- `/notifier-stop` - Stop the service
- `/notifier-status` - Check status
- `/notifier-test` - Send test notification
- `/notifier-uninstall` - Remove everything

See [commands/README.md](commands/README.md) for detailed documentation.

## How Configuration Works

Claude Code reads and merges settings from multiple sources in this order (later overrides earlier):

1. `settings.json` - Project defaults (in git)
2. `settings.local.json` - Your personal overrides (gitignored)
3. `~/.claude/settings.json` - Global user settings

This allows:
- ✅ Project to define defaults
- ✅ Each user to have their own Chat ID
- ✅ Sensitive data stays out of git
- ✅ Easy setup for new users

## Quick Setup

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd ClaudeNotifier
   ```

2. **Create local configuration**
   ```bash
   cp .claude/settings.local.json.example .claude/settings.local.json
   ```

3. **Get your Chat ID**
   - Start the bot: `/notifier-start`
   - Open your bot in Telegram
   - Send `/start` command
   - Copy the Chat ID from bot's response

4. **Update local configuration**
   Edit `.claude/settings.local.json`:
   ```json
   {
     "env": {
       "TELEGRAM_CHAT_ID": "your-actual-chat-id-here"
     }
   }
   ```

5. **Test**
   ```bash
   /notifier-test
   ```

## Security Notes

- ✅ `settings.local.json` is gitignored
- ✅ `application-local.yml` is gitignored
- ✅ Tokens and Chat IDs never go to repository
- ✅ Each developer has their own credentials
- ⚠️ Never commit `settings.local.json` or files with real credentials

## Troubleshooting

### Chat ID not found
If hooks can't find your Chat ID:

1. Check `.claude/settings.local.json` exists
2. Verify it contains valid JSON
3. Make sure `TELEGRAM_CHAT_ID` is set
4. Try restarting Claude Code

### Hooks not working
1. Check hooks are executable: `chmod +x .claude/hooks/*.sh`
2. Verify bot service is running: `/notifier-status`
3. Check logs in `notifier.log`

### Need help?
Run `/notifier-status` to see complete diagnostics.
