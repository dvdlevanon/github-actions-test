#!/bin/bash

set -e

if [ -z "$1" ]; then
  echo "Error: Duration parameter required (e.g., 1h, 2h, 3h)"
  exit 1
fi

DURATION=$1
DURATION_HOURS=$(echo "$DURATION" | sed 's/h$//')
if ! [[ "$DURATION_HOURS" =~ ^[0-9]+$ ]]; then
  echo "Error: Invalid duration format. Use format like '1h', '2h', etc."
  exit 1
fi
START_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TEST_RUN_ID=$(date +%Y-%m-%d-%H-%M) 
RUN_FILE="run.json"

cat > "$RUN_FILE" <<EOF
{
  "start_time": "$START_TIME",
  "duration_hours": $DURATION_HOURS,
  "started_by": "github-actions-workflow",
  "run_id": "$TEST_RUN_ID"
}
EOF

echo "Created run metadata: $RUN_FILE"
echo "  Start time: $START_TIME"
echo "  Duration: ${DURATION_HOURS}h"
echo "  Run ID: ${TEST_RUN_ID}"

echo "Test run initialized successfully"
