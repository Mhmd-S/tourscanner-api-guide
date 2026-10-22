"""Live slots for one activity on one date.
Usage: python3 availability.py <activityId> <YYYY-MM-DD> [adults]
"""
import json
import os
import sys
import urllib.request

BASE = os.environ.get("TOURSCANNER_BASE_URL", "https://tourscanner.ai")
key = os.environ.get("TOURSCANNER_API_KEY")
if not key:
    sys.exit("Set TOURSCANNER_API_KEY first")
if len(sys.argv) < 3:
    sys.exit("Usage: python3 availability.py <activityId> <YYYY-MM-DD> [adults]")

body = {
    "activityId": int(sys.argv[1]),
    "date": sys.argv[2],
    "adults": int(sys.argv[3]) if len(sys.argv) > 3 else 2,
}
req = urllib.request.Request(
    f"{BASE}/api/availability/slots",
    data=json.dumps(body).encode(),
    headers={"X-API-Key": key, "Content-Type": "application/json"},
)
with urllib.request.urlopen(req) as res:
    slots = json.load(res).get("slots", [])

if not slots:
    print("No slots on that date. Try another one.")
for s in slots:
    state = "open    " if s["available"] else "sold out"
    print(f"{s['startTime']}  {state}  {s['totalPrice'] / 100:.2f} {s['currency']}  {s.get('label', '')}")
