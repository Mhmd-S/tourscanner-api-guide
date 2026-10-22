# TourScanner API guide

How to use the [TourScanner](https://tourscanner.ai) API: search tours and activities, check live availability, and book them. It also covers the MCP server, if you want an AI agent to do the same thing.

The catalog is about a million activities from 14 providers, behind one set of endpoints. This repo is the practical side of the docs: what to call, in what order, and the mistakes that cost people an afternoon.

Reference docs live at [tourscanner.ai/docs](https://tourscanner.ai/docs), and the machine-readable spec is at [tourscanner.ai/openapi.json](https://tourscanner.ai/openapi.json).

## Get a key

Keys are issued by hand. Email api@tourscanner.ai with what you're building and which cities matter to you. Send it in the `X-API-Key` header on every request. Without one you get a `401`.

```sh
export TOURSCANNER_API_KEY=your_key
```

## First request

```sh
curl -s "https://tourscanner.ai/api/search/activities?city=rome&q=colosseum&limit=3" \
  -H "X-API-Key: $TOURSCANNER_API_KEY"
```

You get back `activities`, plus `total`, `page` and some facets. Each activity has an `id`, a name, a rating, and a `price` of the form `{ "currency": "EUR", "price": 5400 }`.

Prices are integers in minor units, so `5400` is 54.00. This applies to the `min_price` and `max_price` filters too.

## The booking flow

Five calls, in this order:

1. `GET /api/search/activities` to find something.
2. `POST /api/availability/slots` for the real slots and prices on a date.
3. `POST /api/booking/options` for the ticket variants and booking questions.
4. `POST /api/booking/hold` reserves the slot and returns a Stripe `checkoutUrl`. The card is authorized, not charged.
5. `POST /api/booking/confirm` after the customer pays. This confirms with the supplier and captures the payment.

Details and request bodies are in [docs/booking.md](docs/booking.md). A runnable version of steps 1 to 4 is in [examples/book.mjs](examples/book.mjs).

## Examples

All of them read `TOURSCANNER_API_KEY` from the environment. Node 18 or newer, no dependencies.

```sh
node examples/search.mjs rome "colosseum"
node examples/availability.mjs 12345 2026-12-01
python3 examples/search.py rome colosseum
```

## For AI agents

There's a remote MCP server at `https://tourscanner.ai/api/mcp`. It exposes 12 tools covering search, availability, checkout links, and booking status. Setup for Claude, Cursor, VS Code and others is in [docs/mcp.md](docs/mcp.md).

## Things that trip people up

- **Cents, not euros.** Every price field is in minor units.
- **`productOptionCode` comes from `booking/options`.** The hold fails without it, and the codes differ per activity.
- **`adults` is required** in `passengers`, and it has to be at least 1.
- **Phone numbers need the country code**, like `+393331234567`. Anything else is rejected.
- **Stripe sessions expire after 30 minutes.** After that the hold is released.
- **Check availability right before booking.** Search results come from our catalog, and slots come live from the supplier. They can disagree.
- **Not every provider books in-house.** For the others you hand the traveller off to the partner instead. Adding `providers=2,3,7` to a search limits it to the ones we book directly. The MCP `get_activity` tool reports this per activity as `bookableByUs`.
- **Rate limits return `429`** with a `Retry-After` header. Honor it.

## Environments

The production host places real holds and real Stripe checkouts. If you want a sandbox on provider test rails, ask for one when you get your key.

## License

MIT for the code in this repo. The catalog content you get from the API is covered by the [terms](https://tourscanner.ai/terms).
