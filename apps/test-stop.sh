#!/bin/bash

RUN_FILE="run.json"
AUTO_MODE=false
if [ "$1" == "--auto" ]; then
  AUTO_MODE=true
fi

stop_test_and_exit() {
	rm -f "$RUN_FILE"
	echo "Deleted $RUN_FILE"

	echo "Test stopped successfully"
	exit 0
}

if [ "$AUTO_MODE" != true ]; then
	echo "Mode: Manual trigger - forcing stop"
	stop_test_and_exit
fi

if [ ! -f "$RUN_FILE" ]; then
	echo "run.json missing - stopping!"
	stop_test_and_exit
fi

START_TIME=$(jq -r '.start_time' "$RUN_FILE")
if [ $? -ne 0 ]; then
	echo "ERROR: Failed to read start_time from run.json - stopping!"
	stop_test_and_exit
fi

if [ "$START_TIME" == "null" ] || [ -z "$START_TIME" ]; then
	echo "ERROR: start_time is null or empty in run.json - stopping!"
	stop_test_and_exit
fi

DURATION_HOURS=$(jq -r '.duration_hours' "$RUN_FILE")
if [ $? -ne 0 ]; then
	echo "ERROR: Failed to read duration_hours from run.json - stopping!"
	stop_test_and_exit
fi

if [ "$DURATION_HOURS" == "null" ] || [ -z "$DURATION_HOURS" ]; then
	echo "ERROR: duration_hours is null or empty in run.json - stopping!"
	stop_test_and_exit
fi

START_EPOCH=$(date -d "$START_TIME" +%s)
if [ $? -ne 0 ]; then
	echo "ERROR: Failed to parse start_time date format - stopping!"
	stop_test_and_exit
fi

CURRENT_EPOCH=$(date +%s)
ELAPSED_SECONDS=$((CURRENT_EPOCH - START_EPOCH))
ELAPSED_HOURS=$((ELAPSED_SECONDS / 3600))
DURATION_SECONDS=$((DURATION_HOURS * 3600))

echo "Current run details:"
echo "  Started: $START_TIME"
echo "  Duration: ${DURATION_HOURS}h"
echo "  Elapsed time: ${ELAPSED_HOURS}h"

if [ $ELAPSED_SECONDS -lt $DURATION_SECONDS ]; then
	REMAINING_HOURS=$(( (DURATION_SECONDS - ELAPSED_SECONDS) / 3600 ))
	echo "Duration not yet exceeded. Remaining: ~${REMAINING_HOURS}h. Skipping stop."
	exit 0
fi

echo "Duration exceeded. Stopping run."
stop_test_and_exit
