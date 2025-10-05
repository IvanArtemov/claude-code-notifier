# Start Claude Code Telegram Notifier Service

You are helping the user start the Claude Code Telegram Notifier bot service.

## Step 1: Check if Already Running

First, check if the service is already running:

```bash
curl -s http://localhost:8080/api/health
```

If you get `{"status":"UP"}`, inform the user:
"The notifier service is already running on port 8080."

Ask: "Do you want to restart it?"
- If no: Exit
- If yes: Continue to step 2

## Step 2: Check Configuration

Verify that configuration file exists:

```bash
ls -la src/main/resources/application-local.yml
```

If the file doesn't exist:
- Inform the user: "Configuration file not found. Please run `/notifier-setup` first to configure the bot."
- Exit

## Step 3: Find and Stop Existing Process (if needed)

If restarting, find the existing process:

```bash
# Find Gradle bootRun process
ps aux | grep "gradlew bootRun" | grep -v grep

# Or Java process
ps aux | grep "ClaudeNotifierApplication" | grep -v grep
```

If found, ask: "I found a running instance. Should I stop it first?"

If yes, get the PID and kill:
```bash
kill [PID]
```

Wait 2-3 seconds to ensure it stopped.

## Step 4: Start the Service

Explain to the user:
"I will start the Telegram bot service in the background. This will run the Spring Boot application that handles notifications."

Ask: "How would you like to run the service?"

### Option A: Current Terminal (Simple)
```bash
./gradlew bootRun
```
Note: This will occupy the current terminal. Press Ctrl+C to stop.

### Option B: Background Process (Recommended)
```bash
nohup ./gradlew bootRun > notifier.log 2>&1 &
echo $! > notifier.pid
```
Note: This runs in the background. Logs are saved to `notifier.log`. PID is saved to `notifier.pid`.

Execute the chosen option.

## Step 5: Wait for Startup

Explain: "Waiting for the service to start... This may take 10-30 seconds."

Wait and periodically check (every 3 seconds, max 10 attempts):
```bash
curl -s http://localhost:8080/api/health
```

Show startup progress to the user.

## Step 6: Verify Startup

Once health check returns `{"status":"UP"}`:

1. Show success message:
   ```
   ✅ Claude Code Telegram Notifier started successfully!

   Service URL: http://localhost:8080
   Health: http://localhost:8080/api/health
   ```

2. If running in background, show:
   ```
   Process ID: [PID]
   Log file: notifier.log

   To view logs:
   tail -f notifier.log

   To stop:
   /notifier-stop or kill [PID]
   ```

## Step 7: Test Connection (Optional)

Ask: "Would you like to send a test notification to verify the bot is working?"

If yes, run `/notifier-test`

## Troubleshooting

If the service fails to start:

1. **Check logs**:
   ```bash
   cat notifier.log
   # or if running in terminal, check console output
   ```

2. **Common issues**:
   - Port 8080 already in use: "Another application is using port 8080. Stop it or change the port in application-local.yml"
   - Missing configuration: "Run `/notifier-setup` to configure the bot"
   - Invalid bot token: "Check your bot token in application-local.yml"
   - Java not found: "Install Java 21 or set JAVA_HOME"

3. **Show the error** to the user and help them resolve it

## Final Message

```
🚀 Service is running!

Your Telegram bot is now active and will send notifications when:
- Claude Code finishes responding (Stop hook)
- Claude Code is waiting for your input (Notification hook)

Commands:
- /notifier-status - Check service status
- /notifier-stop - Stop the service
- /notifier-test - Send test notification

Note: If you restart your computer, run /notifier-start again to restart the service.
```

---

**Important**: Always confirm successful startup before finishing. If anything fails, help the user debug the issue.
