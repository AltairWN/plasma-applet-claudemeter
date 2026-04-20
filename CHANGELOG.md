# Changelog

## 0.3.0 - 2026-04-20

- Replace hardcoded Sonnet weekly bar with dynamic per-model weeklies: the widget now shows any active `seven_day_*` entry returned by the API (e.g. Opus, Cowork), so new model tiers appear without a widget update
- Labels are derived from the API key name (e.g. `seven_day_opus` becomes "Weekly (Opus)")
- Gauge "Weekly Sonnet" option replaced with "Weekly (top model)", which tracks the most-utilized per-model weekly. Existing configs pointing at `seven_day_sonnet` map to this automatically
- Compact bar strip now sizes itself to the actual number of active limits instead of a fixed 3

## 0.2.0 - 2026-03-09

- Add rate limiting with cooldown and exponential backoff to avoid hammering the API
- Cache successful responses to disk; serve cached data on HTTP 429
- Add 30s fetch timeout with DataSource disconnect to recover from hung requests
- Fix timeout recovery: disconnect DataSource so subsequent fetches aren't silently blocked
- Fix cache read crash on corrupt JSON (now falls through to error message)
- Show "Request timed out" error instead of silently clearing the loading state
- Show "Cached" label with original fetch timestamp when serving cached data
- Fix initial lastUpdated from current time to epoch so first-fetch errors surface properly

## 0.1.0 - 2026-02-14

Initial release.

- Display three rate limit windows: 5-hour, 7-day (all models), 7-day (Sonnet)
- Two compact panel styles: stacked bars and circular gauge
- Configurable warning/critical thresholds with color coding
- Customizable bar colors
- Auto-refresh on configurable polling interval
- Secure token handling (passed via stdin, never as CLI argument)
