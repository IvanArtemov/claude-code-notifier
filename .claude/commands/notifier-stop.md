# Stop Claude Code Telegram Notifier Service

You are helping the user stop the Claude Code Telegram Notifier bot service.

## Step 1: Check if Service is Running

First, verify if the service is currently running:

```bash
curl -s http://localhost:8080/api/health
```

If the connection fails or times out:
- Inform the user: "The notifier service doesn't appear to be running on port 8080."
- Ask: "Would you like me to check for any orphaned processes anyway?"

## Step 2: Find Running Processes

Look for running processes:

### Method 1: Check PID file (if exists)
```bash
if [ -f notifier.pid ]; then
  PID=$(cat notifier.pid)
  echo "Found PID file: $PID"
fi
```

### Method 2: Find by process name
```bash
# Find Gradle bootRun process
ps aux | grep "[g]radlew bootRun" | awk '{print $2}'

# Find Java process
ps aux | grep "[C]laudeNotifierApplication" | awk '{print $2}'

# Find by port
lsof -ti:8080
```

Show the user what processes were found.

## Step 3: Ask for Confirmation

If processes are found, show them to the user:
```
Found running processes:
PID     Command
[PID1]  ./gradlew bootRun
[PID2]  java -jar ...

Do you want to stop these processes?
```

Wait for user confirmation before proceeding.

## Step 4: Stop the Processes

Explain: "I will gracefully stop the service by sending a TERM signal. If that doesn't work, I'll force stop it."

### Graceful Stop (SIGTERM)
```bash
kill [PID]
```

Wait 5 seconds and check if process stopped:
```bash
ps -p [PID] > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Process stopped successfully"
fi
```

### Force Stop if needed (SIGKILL)
If process is still running after 5 seconds:
```bash
kill -9 [PID]
echo "Process force-stopped"
```

## Step 5: Cleanup

1. **Remove PID file** (if exists):
   ```bash
   rm -f notifier.pid
   ```

2. **Verify port is free**:
   ```bash
   lsof -ti:8080
   ```
   If nothing is returned, port 8080 is now free.

3. **Check health endpoint**:
   ```bash
   curl -s http://localhost:8080/api/health
   ```
   Should fail/timeout (confirming service is stopped).

## Step 6: Confirmation Message

Show success message:
```
✅ Claude Code Telegram Notifier stopped successfully!

Service is no longer running on port 8080.
Telegram notifications are now disabled.

To start the service again:
/notifier-start

To check status:
/notifier-status
```

## Troubleshooting

### If unable to stop process:

1. **Permission denied**:
   ```
   The process is owned by another user. You may need sudo:
   sudo kill [PID]
   ```

2. **Process doesn't exist**:
   ```
   The process may have already stopped. Running cleanup...
   ```

3. **Multiple processes found**:
   List all PIDs and ask user which ones to stop, or offer to stop all.

### Logs Preservation

Ask the user: "Would you like to keep the log file (notifier.log) or delete it?"

If delete:
```bash
rm -f notifier.log
```

If keep:
```bash
mv notifier.log notifier.log.$(date +%Y%m%d_%H%M%S)
echo "Log file archived"
```

## Additional Cleanup (Optional)

Ask: "Would you like to perform additional cleanup?"

If yes, offer options:
- Remove log files: `rm -f notifier.log*`
- Remove PID files: `rm -f notifier.pid`
- Keep configuration for next start

---

**Important**:
- Always confirm processes before killing them
- Use SIGTERM before SIGKILL for graceful shutdown
- Verify the service is actually stopped before confirming success
