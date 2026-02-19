#!/usr/bin/env bash
# browser-use-cleanup: find and remove orphaned browser-use temp directories
# Usage: ./cleanup.sh [--dry-run]

set -euo pipefail

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

# Resolve actual temp directory (macOS uses /var/folders, not /tmp)
TMPDIR_ACTUAL=$(python3 -c "import tempfile; print(tempfile.gettempdir())" 2>/dev/null || echo "/tmp")

echo "=== Browser-Use Session Cleanup ==="
echo "Temp directory: $TMPDIR_ACTUAL"
echo ""

# Check for running browser-use processes
RUNNING=$(pgrep -fl "browser.use" 2>/dev/null || true)
if [[ -n "$RUNNING" ]]; then
    echo "WARNING: browser-use processes are running:"
    echo "$RUNNING"
    echo ""
    if [[ "$DRY_RUN" == false ]]; then
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        [[ ! $REPLY =~ ^[Yy]$ ]] && { echo "Aborted."; exit 1; }
    fi
else
    echo "No active browser-use processes found."
fi
echo ""

# Scan for orphaned user-data profiles
PROFILE_DIRS=()
while IFS= read -r -d '' dir; do
    PROFILE_DIRS+=("$dir")
done < <(find "$TMPDIR_ACTUAL" -maxdepth 1 -type d -name "browser-use-user-data-dir-*" -print0 2>/dev/null)

PROFILE_COUNT=${#PROFILE_DIRS[@]}
if [[ $PROFILE_COUNT -gt 0 ]]; then
    PROFILE_SIZE=$(du -ch "${PROFILE_DIRS[@]}" 2>/dev/null | tail -1 | cut -f1)
else
    PROFILE_SIZE="0B"
fi

# Scan for download stubs
DOWNLOAD_DIRS=()
while IFS= read -r -d '' dir; do
    DOWNLOAD_DIRS+=("$dir")
done < <(find /tmp -maxdepth 1 -type d -name "browser-use-downloads-*" -print0 2>/dev/null)

DOWNLOAD_COUNT=${#DOWNLOAD_DIRS[@]}
if [[ $DOWNLOAD_COUNT -gt 0 ]]; then
    DOWNLOAD_SIZE=$(du -ch "${DOWNLOAD_DIRS[@]}" 2>/dev/null | tail -1 | cut -f1)
else
    DOWNLOAD_SIZE="0B"
fi

# Report
echo "--- Findings ---"
echo "Chromium user-data profiles: $PROFILE_COUNT dirs ($PROFILE_SIZE)"
echo "  Location: $TMPDIR_ACTUAL/browser-use-user-data-dir-*"
echo ""
echo "Download stubs:              $DOWNLOAD_COUNT dirs ($DOWNLOAD_SIZE)"
echo "  Location: /tmp/browser-use-downloads-*"
echo ""

TOTAL=$((PROFILE_COUNT + DOWNLOAD_COUNT))
if [[ $TOTAL -eq 0 ]]; then
    echo "Nothing to clean up."
    exit 0
fi

if [[ "$DRY_RUN" == true ]]; then
    echo "[dry-run] Would delete $TOTAL directories."
    exit 0
fi

# Clean up
echo "Deleting $TOTAL directories..."

if [[ $PROFILE_COUNT -gt 0 ]]; then
    rm -rf "$TMPDIR_ACTUAL"/browser-use-user-data-dir-*
    echo "  Removed $PROFILE_COUNT user-data profiles."
fi

if [[ $DOWNLOAD_COUNT -gt 0 ]]; then
    rm -rf /tmp/browser-use-downloads-*
    echo "  Removed $DOWNLOAD_COUNT download stubs."
fi

# Verify
REMAINING_PROFILES=$(find "$TMPDIR_ACTUAL" -maxdepth 1 -type d -name "browser-use-user-data-dir-*" 2>/dev/null | wc -l | tr -d ' ')
REMAINING_DOWNLOADS=$(find /tmp -maxdepth 1 -type d -name "browser-use-downloads-*" 2>/dev/null | wc -l | tr -d ' ')

echo ""
if [[ "$REMAINING_PROFILES" -eq 0 && "$REMAINING_DOWNLOADS" -eq 0 ]]; then
    echo "Cleanup complete. All orphaned directories removed."
else
    echo "WARNING: $REMAINING_PROFILES profiles and $REMAINING_DOWNLOADS download dirs remain."
fi
