# Check Claude Code Telegram Notifier Status

You are helping the user check the status of the Claude Code Telegram Notifier bot service.

## Status Check Overview

Perform a comprehensive status check and present the results in a clear, organized format.

## Step 1: Service Status

Check if the Spring Boot application is running:

```bash
curl -s -w "\n%{http_code}" http://localhost:8080/api/health --connect-timeout 2
```

Parse the response:
- **200 + {"status":"UP"}**: ✅ Service is running
- **Connection refused/timeout**: ❌ Service is not running
- **Other**: ⚠️ Service is running but unhealthy

## Step 2: Process Information

Look for running processes:

```bash
# Check PID file
if [ -f notifier.pid ]; then
  PID=$(cat notifier.pid)
  if ps -p $PID > /dev/null 2>&1; then
    echo "PID: $PID (from notifier.pid) - RUNNING"
  else
    echo "PID file exists but process is not running (stale PID)"
  fi
fi

# Find by process name
GRADLE_PID=$(ps aux | grep "[g]radlew bootRun" | awk '{print $2}')
JAVA_PID=$(ps aux | grep "[C]laudeNotifierApplication" | awk '{print $2}')

# Find by port
PORT_PID=$(lsof -ti:8080 2>/dev/null)
```

Show:
- Process ID(s)
- CPU and memory usage
- Uptime (if possible)

## Step 3: Configuration Check

Verify configuration files exist:

```bash
# Local configuration
if [ -f src/main/resources/application-local.yml ]; then
  echo "✅ Local configuration: src/main/resources/application-local.yml"
else
  echo "❌ Local configuration: NOT FOUND"
fi

# Global Claude hooks
if [ -f ~/.claude/settings.json ]; then
  echo "✅ Global Claude settings: ~/.claude/settings.json"
  # Check if hooks are configured
  if grep -q "task-complete.sh" ~/.claude/settings.json 2>/dev/null; then
    echo "  ✅ Stop hook configured"
  fi
  if grep -q "notification.sh" ~/.claude/settings.json 2>/dev/null; then
    echo "  ✅ Notification hook configured"
  fi
else
  echo "❌ Global Claude settings: NOT FOUND"
fi

# Hook scripts
if [ -x ~/.claude/hooks/task-complete.sh ]; then
  echo "✅ Task completion hook: ~/.claude/hooks/task-complete.sh"
else
  echo "❌ Task completion hook: NOT FOUND or not executable"
fi

if [ -x ~/.claude/hooks/notification.sh ]; then
  echo "✅ Notification hook: ~/.claude/hooks/notification.sh"
else
  echo "❌ Notification hook: NOT FOUND or not executable"
fi
```

## Step 4: Environment Variables Check

Check if required environment variables are set (from global Claude settings):

```bash
# Extract from ~/.claude/settings.json
if [ -f ~/.claude/settings.json ]; then
  CHAT_ID=$(jq -r '.env.TELEGRAM_CHAT_ID // empty' ~/.claude/settings.json 2>/dev/null)
  BOT_URL=$(jq -r '.env.CLAUDE_NOTIFIER_URL // empty' ~/.claude/settings.json 2>/dev/null)

  if [ -n "$CHAT_ID" ]; then
    echo "✅ TELEGRAM_CHAT_ID: ${CHAT_ID:0:3}***${CHAT_ID: -3} (masked)"
  else
    echo "❌ TELEGRAM_CHAT_ID: Not set"
  fi

  if [ -n "$BOT_URL" ]; then
    echo "✅ CLAUDE_NOTIFIER_URL: $BOT_URL"
  else
    echo "❌ CLAUDE_NOTIFIER_URL: Not set"
  fi
fi
```

## Step 5: Network/Port Check

Check if port 8080 is accessible:

```bash
# Check if port is in use
if lsof -ti:8080 > /dev/null 2>&1; then
  echo "✅ Port 8080: IN USE (service is listening)"
else
  echo "❌ Port 8080: NOT IN USE (no service listening)"
fi

# Test actual connectivity
if curl -s http://localhost:8080/api/health > /dev/null 2>&1; then
  echo "✅ HTTP endpoint: ACCESSIBLE"
else
  echo "❌ HTTP endpoint: NOT ACCESSIBLE"
fi
```

## Step 6: Log Files

Check for log files and show recent entries:

```bash
if [ -f notifier.log ]; then
  LOG_SIZE=$(du -h notifier.log | cut -f1)
  LOG_LINES=$(wc -l < notifier.log)
  echo "📄 Log file: notifier.log ($LOG_SIZE, $LOG_LINES lines)"
  echo ""
  echo "Last 5 lines:"
  tail -5 notifier.log
else
  echo "ℹ️  No log file found (may be logging to console)"
fi
```

## Step 7: Build Status

Check when the last build was done:

```bash
if [ -d build/libs ]; then
  JAR_FILE=$(ls -t build/libs/*.jar 2>/dev/null | head -1)
  if [ -n "$JAR_FILE" ]; then
    JAR_DATE=$(ls -lh "$JAR_FILE" | awk '{print $6, $7, $8}')
    JAR_SIZE=$(ls -lh "$JAR_FILE" | awk '{print $5}')
    echo "📦 Last build: $JAR_DATE ($JAR_SIZE)"
  fi
else
  echo "⚠️  No build found - run './gradlew build' first"
fi
```

## Final Status Report

Present a comprehensive status report:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 CLAUDE CODE TELEGRAM NOTIFIER - STATUS REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔧 SERVICE STATUS
[✅/❌] Service: [RUNNING/STOPPED]
[✅/❌] Health Check: [HEALTHY/UNHEALTHY]
[✅/❌] Process: PID [NUMBER] ([CPU]% CPU, [MEM] MB)
[✅/❌] Port 8080: [LISTENING/NOT LISTENING]

📁 CONFIGURATION
[✅/❌] Application Config: [FOUND/NOT FOUND]
[✅/❌] Global Claude Settings: [FOUND/NOT FOUND]
[✅/❌] Stop Hook: [CONFIGURED/NOT CONFIGURED]
[✅/❌] Notification Hook: [CONFIGURED/NOT CONFIGURED]

🔐 ENVIRONMENT
[✅/❌] TELEGRAM_CHAT_ID: [SET/NOT SET]
[✅/❌] CLAUDE_NOTIFIER_URL: [SET/NOT SET]

📊 HOOKS STATUS
[✅/❌] ~/.claude/hooks/task-complete.sh: [EXISTS/MISSING]
[✅/❌] ~/.claude/hooks/notification.sh: [EXISTS/MISSING]

📦 BUILD
[✅/❌] JAR file: [FOUND/NOT FOUND]
Last build: [DATE/NEVER]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 RECOMMENDATIONS:
[List any issues found and how to fix them]

📝 NEXT STEPS:
[Suggest commands based on current state]
```

## Provide Recommendations

Based on the status, provide actionable recommendations:

### If service is not running:
```
The service is not running. To start it:
/notifier-start
```

### If configuration is missing:
```
Configuration not found. To set up the notifier:
/notifier-setup
```

### If hooks are not installed:
```
Global hooks are not installed. Run /notifier-setup to install them.
```

### If everything is working:
```
✅ Everything looks good! Your notifier is active and ready.

Test it with:
/notifier-test
```

---

**Important**: Always provide a clear, visual status report that's easy to understand at a glance. Use emojis and formatting to make it readable.
