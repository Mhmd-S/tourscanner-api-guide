// Search activities in a city. Usage: node search.mjs <city> [query]
const BASE = process.env.TOURSCANNER_BASE_URL ?? 'https://tourscanner.ai'
const key = process.env.TOURSCANNER_API_KEY
if (!key) throw new Error('Set TOURSCANNER_API_KEY first')

const [city = 'rome', q] = process.argv.slice(2)
const params = new URLSearchParams({ city, limit: '5' })
if (q) params.set('q', q)

const res = await fetch(`${BASE}/api/search/activities?${params}`, {
  headers: { 'X-API-Key': key },
})
if (!res.ok) throw new Error(`${res.status} ${await res.text()}`)

const { activities, total } = await res.json()
console.log(`${total} activities in ${city}\n`)

for (const a of activities) {
  // price is in minor units: 5400 means 54.00
  const price = a.price ? `${(a.price.price / 100).toFixed(2)} ${a.price.currency}` : 'no price'
  console.log(`${a.id}  ${a.name}  (${a.reviews_avg ?? '-'} stars, ${price})`)
}
