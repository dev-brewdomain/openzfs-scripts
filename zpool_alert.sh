#!/bin/bash

# ================= Configuration =================
POOL_NAME="RAIDZ0"                      # Name of your ZFS pool (e.g., tank, data, pool01)
THRESHOLD=80                          # Alert threshold percentage
EMAIL="mechadevices@gmail.com"          # Recipient email address
HOSTNAME=$(hostname)                  # Include server name in alerts
# =================================================

# Get ZFS pool capacity percentage (removes the '%' sign)
USAGE=$(zpool list -H -o capacity "$POOL_NAME" 2>/dev/null | tr -d '%')

# Validate that USAGE retrieved successfully and is a number
if ! [[ "$USAGE" =~ ^[0-9]+$ ]]; then
    echo "Error: Could not retrieve capacity for ZFS pool '$POOL_NAME'." >&2
    exit 1
fi

# Check if usage meets or exceeds threshold
if [ "$USAGE" -ge "$THRESHOLD" ]; then
    SUBJECT="CRITICAL: ZFS Pool '$POOL_NAME' at ${USAGE}% on $HOSTNAME"
    
    # Gather additional pool status details to include in the email body
    POOL_STATUS=$(zpool status "$POOL_NAME" 2>/dev/null)
    
    BODY="Warning:\n\nThe ZFS storage pool '$POOL_NAME' has reached ${USAGE}% capacity.\nThis exceeds your configured threshold of ${THRESHOLD}%.\n\n--- Pool Status ---\n$POOL_STATUS\n\nPlease investigate and free up space immediately."

    # Send email using the local mail command
    echo -e "$BODY" | mail -s "$SUBJECT" "$EMAIL"
    
    echo "Alert sent: ZFS pool '$POOL_NAME' is at ${USAGE}%."
else
    echo "ZFS pool '$POOL_NAME' is healthy at ${USAGE}%."
fi
