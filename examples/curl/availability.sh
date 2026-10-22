#!/bin/sh
# Live slots for one activity on one date. Usage: ./availability.sh <activityId> <YYYY-MM-DD> [adults]
: "${TOURSCANNER_API_KEY:?Set TOURSCANNER_API_KEY first}"
BASE="${TOURSCANNER_BASE_URL:-https://tourscanner.ai}"

curl -s -X POST "$BASE/api/availability/slots" \
  -H "X-API-Key: $TOURSCANNER_API_KEY" -H "Content-Type: application/json" \
  -d "{\"activityId\": $1, \"date\": \"$2\", \"adults\": ${3:-2}}"
