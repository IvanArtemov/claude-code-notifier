# Claude Code Telegram Notifier - Commands

This directory contains slash commands for managing the Claude Code Telegram Notifier bot.

## Available Commands

### 🚀 Setup & Installation

#### `/notifier-setup`
**Complete interactive setup wizard**

Sets up the entire Telegram notifier system from scratch. This command will:
- Check prerequisites (Java 21, Gradle)
- Collect Telegram bot credentials (token, username, chat ID)
- Create configuration files
- Build the Spring Boot application
- Start the service
- Install global Claude Code hooks
- Test the installation

**Usage:**
```
/notifier-setup
```

**When to use:** First time installation or complete reconfiguration

---

### 🎮 Service Management

#### `/notifier-start`
**Start the notifier service**

Starts the Telegram bot service in the background. Checks if the service is already running and offers restart option if needed.

**Usage:**
```
/notifier-start
```

**Options:**
- Run in current terminal (blocks terminal)
- Run in background (recommended)

**When to use:** After system restart or when service is stopped

---

#### `/notifier-stop`
**Stop the notifier service**

Gracefully stops the running Telegram bot service. Finds all related processes and terminates them safely.

**Usage:**
```
/notifier-stop
```

**What it does:**
- Finds running Gradle/Java processes
- Sends SIGTERM for graceful shutdown
- Forces stop with SIGKILL if needed
- Cleans up PID files

**When to use:** When you want to temporarily disable notifications or restart the service

---

#### `/notifier-status`
**Check comprehensive status**

Provides a detailed status report of the entire notifier system.

**Usage:**
```
/notifier-status
```

**Information shown:**
- ✅ Service running status
- ✅ Process information (PID, CPU, memory)
- ✅ Configuration files status
- ✅ Global hooks status
- ✅ Environment variables
- ✅ Network/port status
- ✅ Recent logs
- ✅ Build status

**When to use:** Troubleshooting, verifying installation, or general health check

---

### 🧪 Testing

#### `/notifier-test`
**Send test notification**

Sends a test notification to your Telegram to verify everything is working correctly.

**Usage:**
```
/notifier-test
```

**What it does:**
- Verifies service is running
- Checks Chat ID configuration
- Sends test message to Telegram
- Helps troubleshoot if message not received

**When to use:** After setup, after configuration changes, or when troubleshooting

---

### 🗑️ Uninstallation

#### `/notifier-uninstall`
**Complete removal**

Removes the notifier from your system. **Use with caution!**

**Usage:**
```
/notifier-uninstall
```

**What it removes:**
- Stops the running service
- Removes global Claude Code hooks
- Removes hook scripts from `~/.claude/hooks/`
- Optionally removes configuration files
- Optionally removes build directory
- Optionally removes entire project

**Safety features:**
- Creates backup before removal
- Requires confirmation for destructive actions
- Double confirmation for project deletion

**When to use:** When you no longer want to receive Telegram notifications

---

## Quick Start Guide

### First Time Setup
1. Run `/notifier-setup`
2. Follow the interactive prompts
3. Provide bot token and username
4. Test with `/notifier-test`

### Daily Usage
- Service runs automatically once started
- Receive notifications when Claude finishes or waits
- No manual interaction needed

### Common Operations

**Check if running:**
```
/notifier-status
```

**Restart service:**
```
/notifier-stop
/notifier-start
```

**Test notifications:**
```
/notifier-test
```

---

## Notification Types

The bot sends two types of notifications:

### 1. Session Complete (Stop Hook)
Triggered when Claude Code finishes responding.

**Contains:**
- Last user request (truncated)
- Number of tools used
- Total messages in session
- Completion timestamp

### 2. Waiting for Input (Notification Hook)
Triggered when Claude Code is idle for 60+ seconds.

**Contains:**
- Last Claude message/question
- Session ID
- Timestamp

---

## Troubleshooting

### Service won't start
```
/notifier-status  # Check what's wrong
```

Common issues:
- Port 8080 in use → Stop other apps using that port
- Missing configuration → Run `/notifier-setup` again
- Invalid bot token → Check `application-local.yml`

### No notifications received
```
/notifier-test  # Verify Telegram connection
```

Common issues:
- Wrong Chat ID → Get correct ID via `/start` in Telegram
- Service not running → Run `/notifier-start`
- Hooks not installed → Run `/notifier-setup` again

### Service stops after closing terminal
Use background mode when starting:
- Run `/notifier-start` and choose background option
- Or use: `nohup ./gradlew bootRun > notifier.log 2>&1 &`

---

## Files and Locations

### Project Files
- `src/main/resources/application-local.yml` - Bot credentials (gitignored)
- `notifier.log` - Service logs (if running in background)
- `notifier.pid` - Process ID file

### Global Files
- `~/.claude/settings.json` - Global Claude Code configuration with hooks
- `~/.claude/hooks/task-complete.sh` - Stop hook script
- `~/.claude/hooks/notification.sh` - Notification hook script

### Backups
- `~/.claude/backups/notifier-[timestamp]/` - Created during uninstall

---

## Advanced Usage

### Running on System Startup

**macOS (LaunchAgent):**
Create `~/Library/LaunchAgents/com.claudecode.notifier.plist`

**Linux (systemd):**
Create `/etc/systemd/system/claude-notifier.service`

**Windows:**
Use Task Scheduler

*(Detailed instructions in main README.md)*

### Custom Port

Edit `src/main/resources/application-local.yml`:
```yaml
server:
  port: 9090  # Your custom port
```

Don't forget to update `~/.claude/settings.json`:
```json
{
  "env": {
    "CLAUDE_NOTIFIER_URL": "http://localhost:9090/api/notify"
  }
}
```

### Multiple Chat IDs

Currently supports one Chat ID. For multiple users:
- Run multiple instances on different ports
- Or modify the code to support multiple recipients

---

## Support

### Getting Help
- Check `/notifier-status` for diagnostics
- Review logs: `tail -f notifier.log`
- Run `/notifier-test` to isolate issues

### Reporting Issues
When reporting issues, include:
1. Output from `/notifier-status`
2. Recent logs from `notifier.log`
3. Steps to reproduce the problem

---

## Command Reference

| Command | Purpose | Risk Level |
|---------|---------|------------|
| `/notifier-setup` | Initial setup | 🟢 Safe |
| `/notifier-start` | Start service | 🟢 Safe |
| `/notifier-stop` | Stop service | 🟢 Safe |
| `/notifier-status` | Check status | 🟢 Safe |
| `/notifier-test` | Send test message | 🟢 Safe |
| `/notifier-uninstall` | Remove everything | 🔴 Destructive |

---

**Tip:** You can chain commands! For example:
```
/notifier-stop
/notifier-start
/notifier-test
```

This will restart the service and send a test notification.