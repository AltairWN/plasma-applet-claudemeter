# Claude Meter

[![Available on the KDE Store](https://img.shields.io/badge/KDE%20Store-Get%20It-blue?logo=kde)](https://www.pling.com/p/2348058/)

A KDE Plasma 6 panel applet that monitors your Claude Code rate limits.

![screenshot.png](screenshot.png)

## Features

- Displays three rate limit windows: 5-hour, 7-day (all models), and 7-day (Sonnet)
- Two compact panel styles: stacked bars or circular gauge
- Configurable warning/critical thresholds with color coding
- Customizable bar colors
- Auto-refreshes on a configurable polling interval
- Warning icon when credentials are missing or the API returns an error

## How It Works

1. Reads the OAuth token from `~/.claude/.credentials.json` (created by the Claude Code CLI when you sign in)
2. Calls `GET https://api.anthropic.com/api/oauth/usage` with a bearer token
3. Parses the response for three rate limit windows, each with a utilization percentage and reset timestamp
4. The token is passed to `curl` via stdin (not as a command-line argument, which would be visible in `/proc`)

> **Note:** This widget uses an internal Anthropic API endpoint that is not part of the public API documentation. It may change or stop working without notice.

## Requirements

- KDE Plasma 6
- Claude Code CLI with an active subscription (Pro or Max)
- `python3`
- `curl`

## Install

### From the KDE Store

Browse to [Claude Meter on the KDE Store](https://www.pling.com/p/2348058/) and click **Install**, or use Discover (KDE's software center) to search for "Claude Meter".

### From source

```sh
git clone https://github.com/p3kj/plasma-applet-claudemeter.git
cd plasma-applet-claudemeter
bash install.sh
```

Then add the "Claude Meter" widget to your panel.

## Uninstall

```sh
kpackagetool6 -t Plasma/Applet -r com.github.p3kj.claudemeter
```

## Configuration

Right-click the widget and select "Configure...". Options include:

- **Panel style** — bars (stacked) or gauge (circular arc)
- **Gauge metric** — which rate limit window to display in gauge mode
- **Poll interval** — how often to fetch usage data (default: 900s)
- **Warning / Critical thresholds** — percentage thresholds for color changes
- **Colors** — customize the normal and warning bar colors

## Troubleshooting

- **Widget shows a warning icon** — make sure you are signed into the Claude Code CLI (`claude` in a terminal). The widget reads your OAuth token from `~/.claude/.credentials.json`, which is created on sign-in.
- **"Unauthorized" or 401 errors** — your token may have expired. Run `claude` again to refresh it.
- **No data after install** — wait for the first poll interval (default 15 minutes), or right-click the widget and reconfigure with a shorter interval for testing.
- **429 "Too Many Requests" errors** — the Anthropic API rate-limits usage polling. The default 15-minute interval should be safe, but if you set a very short poll interval you may get throttled. Increase the interval in the widget configuration if this happens.

## License

[MIT](LICENSE)
