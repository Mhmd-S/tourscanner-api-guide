"""Search activities in a city. Usage: python3 search.py <city> [query]"""
import json
import os
import sys
import urllib.parse
import urllib.request

BASE = os.environ.get("TOURSCANNER_BASE_URL", "https://tourscanner.ai")
key = os.environ.get("TOURSCANNER_API_KEY")
if not key:
    sys.exit("Set TOURSCANNER_API_KEY first")

city = sys.argv[1] if len(sys.argv) > 1 else "rome"
params = {"city": city, "limit": 5}
if len(sys.argv) > 2:
    params["q"] = sys.argv[2]

req = urllib.request.Request(
    f"{BASE}/api/search/activities?" + urllib.parse.urlencode(params),
    headers={"X-API-Key": key},
)
with urllib.request.urlopen(req) as res:
    data = json.load(res)

print(f"{data['total']} activities in {city}\n")
for a in data["activities"]:
    # price is in minor units: 5400 means 54.00
    p = a.get("price")
    price = f"{p['price'] / 100:.2f} {p['currency']}" if p else "no price"
    print(f"{a['id']}  {a['name']}  ({a.get('reviews_avg') or '-'} stars, {price})")
