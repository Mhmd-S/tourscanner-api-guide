// Live slots for one activity on one date. Usage: node availability.mjs <activityId> <YYYY-MM-DD> [adults]
const BASE = process.env.TOURSCANNER_BASE_URL ?? 'https://tourscanner.ai'
const key = process.env.TOURSCANNER_API_KEY
if (!key) throw new Error('Set TOURSCANNER_API_KEY first')

const [activityId, date, adults = '2'] = process.argv.slice(2)
if (!activityId || !date) throw new Error('Usage: node availability.mjs <activityId> <YYYY-MM-DD> [adults]')

const res = await fetch(`${BASE}/api/availability/slots`, {
  method: 'POST',
  headers: { 'X-API-Key': key, 'Content-Type': 'application/json' },
  body: JSON.stringify({ activityId: Number(activityId), date, adults: Number(adults) }),
})
if (!res.ok) throw new Error(`${res.status} ${await res.text()}`)

const { slots = [] } = await res.json()
if (!slots.length) {
  console.log('No slots on that date. Try another one.')
}
for (const s of slots) {
  const total = (s.totalPrice / 100).toFixed(2)
  console.log(`${s.startTime}  ${s.available ? 'open   ' : 'sold out'}  ${total} ${s.currency}  ${s.label ?? ''}`)
}
