#!/bin/sh
# Search activities in a city. Usage: ./search.sh <city> [query]
: "${TOURSCANNER_API_KEY:?Set TOURSCANNER_API_KEY first}"
BASE="${TOURSCANNER_BASE_URL:-https://tourscanner.ai}"

curl -s -G "$BASE/api/search/activities" \
  -H "X-API-Key: $TOURSCANNER_API_KEY" \
  --data-urlencode "city=${1:-rome}" \
  --data-urlencode "q=${2:-}" \
  --data-urlencode "limit=5"
