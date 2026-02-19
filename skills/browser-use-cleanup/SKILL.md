---
name: browser-use-cleanup
description: "Find and delete orphaned browser-use temp profiles and download directories. Reclaims disk space from stale Chromium user-data dirs left behind by browser-use sessions."
user_invocable: true
---

# Browser-Use Session Cleanup

## Goal
Find and safely remove orphaned browser-use temporary directories (Chromium user-data profiles + download stubs) that accumulate after sessions finish or crash.

## Safety rules
1. Always check for running browser-use processes before deleting anything.
2. Never delete directories while a browser-use session is active.
3. Show the user what will be deleted (count + total size) and get confirmation before removing.

## Workflow

### Step 1: Locate temp directory
macOS uses `/var/folders/.../T/` as the real temp dir, not `/tmp`. Detect it:
```bash
TMPDIR_ACTUAL=$(python3 -c "import tempfile; print(tempfile.gettempdir())")
```

### Step 2: Check for running sessions
```bash
pgrep -fl "browser.use" 2>/dev/null
pgrep -fl "chromium.*browser-use" 2>/dev/null
```
If any processes are found, warn the user and abort unless they confirm.

### Step 3: Scan for orphaned directories
Two locations to check:

**Heavy profiles (the real disk hogs):**
```bash
find "$TMPDIR_ACTUAL" -maxdepth 1 -type d -name "browser-use-user-data-dir-*" 2>/dev/null
```

**Download stubs (usually empty, in /tmp):**
```bash
find /tmp -maxdepth 1 -type d -name "browser-use-downloads-*" 2>/dev/null
```

### Step 4: Report findings
Show the user:
- Number of orphaned profile dirs + total size
- Number of download stub dirs + total size
- Whether any browser-use processes are running

### Step 5: Clean up (after user confirmation)
```bash
rm -rf "$TMPDIR_ACTUAL"/browser-use-user-data-dir-*
rm -rf /tmp/browser-use-downloads-*
```

### Step 6: Verify
Confirm both locations are clean after deletion.
