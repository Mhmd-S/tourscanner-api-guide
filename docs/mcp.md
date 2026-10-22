# MCP server

If you'd rather let an agent drive, there's a remote MCP server:

```
https://tourscanner.ai/api/mcp
```

Transport is Streamable HTTP. It needs the same API key as the REST API, including for `initialize` and `tools/list`. Send it as `Authorization: Bearer <key>` or `X-API-Key: <key>`. Clients that can't send headers can use `?api_key=<key>` in the URL instead.

A URL with a key in it is a secret. Don't paste it into tickets or shared docs.

## Tools

| Tool | What it does |
|---|---|
| `search_destinations` | Cities and attractions by name |
| `search_activities` | Activities by keyword, city, attraction, tag, rating, or around a point (`near: { lat, lng, radiusKm }`) |
| `get_activity` | Full detail, prices, bookability |
| `check_availability` | Live slots and prices for a date and party |
| `get_availability_calendar` | Open dates and cheapest price across a range |
| `get_booking_options` | Ticket types, age bands, cancellation policy |
| `create_checkout_session` | Checks the slot live and returns a checkout link |
| `get_booking_status` | Status, voucher and ticket links |
| `get_cancellation_quote` | Whether it's cancellable, and the refund |
| `cancel_booking` | Cancel a booking (demo, changes nothing) |
| `get_amendment_quote` | Quote a date, time, ticket or party change |
| `amend_booking` | Apply a quoted change (demo, changes nothing) |

`create_checkout_session` doesn't book anything by itself. It returns a link, and the traveller pays on that page. Cancel and amend currently return real quotes but don't act.

Booking tools only see bookings made with the key you're calling with.

## Connecting a client

**Claude Code**

```sh
claude mcp add --transport http tourscanner https://tourscanner.ai/api/mcp \
  --header "Authorization: Bearer YOUR_API_KEY"
```

**Claude Desktop** (`claude_desktop_config.json`)

```json
{
  "mcpServers": {
    "tourscanner": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "https://tourscanner.ai/api/mcp",
               "--header", "Authorization: Bearer ${TOURSCANNER_API_KEY}"],
      "env": { "TOURSCANNER_API_KEY": "YOUR_API_KEY" }
    }
  }
}
```

**claude.ai** (Settings, Connectors, Add custom connector). Connectors can't send headers, so the key goes in the URL:

```
https://tourscanner.ai/api/mcp?api_key=YOUR_API_KEY
```

**Cursor** (`.cursor/mcp.json`)

```json
{
  "mcpServers": {
    "tourscanner": {
      "url": "https://tourscanner.ai/api/mcp",
      "headers": { "Authorization": "Bearer YOUR_API_KEY" }
    }
  }
}
```

**VS Code** (`.vscode/mcp.json`)

```json
{
  "servers": {
    "tourscanner": {
      "type": "http",
      "url": "https://tourscanner.ai/api/mcp",
      "headers": { "Authorization": "Bearer YOUR_API_KEY" }
    }
  }
}
```

**Codex CLI** (`~/.codex/config.toml`)

```toml
[mcp_servers.tourscanner]
url = "https://tourscanner.ai/api/mcp"
bearer_token_env_var = "TOURSCANNER_API_KEY"
```

Other clients with remote MCP support work the same way. Point them at the endpoint and send the bearer header. The config formats for Cursor, VS Code and Codex change between releases, so check their docs if one of these doesn't take.

## Check it works

```sh
curl -s -X POST https://tourscanner.ai/api/mcp \
  -H "Authorization: Bearer $TOURSCANNER_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

Then try a prompt: "Find skip-the-line Colosseum tickets for 2 adults next Saturday and check what's open."
