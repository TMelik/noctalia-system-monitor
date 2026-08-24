# System Summary

System Summary combines seven host metrics into one compact Noctalia bar capsule: CPU usage, CPU temperature, RAM, swap, disk usage, download rate, and upload rate. Subtle dividers separate processor, memory, storage, and network groups.

## Plugin

Field | Value
--- | ---
ID | `tmelik/system-summary`
Entries | Bar widget: `summary`
License | GPL-3.0-only

## Requirements

- No external programs or libraries.
- Noctalia v5 with plugin API 16 or newer.
- The Noctalia system monitor service must be enabled.

## Usage

1. Open Noctalia Settings.
2. Go to **Bar**, add a plugin widget, and select **System Summary**.
3. Place the widget in the desired section of the bar.

Left-click the capsule to open the **System** tab in Control Center. Hover it to see the full metric names and values.

Middle-click the capsule to open its settings. Each metric can be shown or hidden independently. You can also toggle category separators and the detailed tooltip, choose compact or explicit network units, and change the monitored disk path. The default path is the root filesystem (`/`).

Unavailable sensors are displayed as an em dash instead of a misleading zero. Network rates are totals across active non-loopback interfaces. RAM uses a distinct server-module glyph so it is easy to tell apart from CPU at a glance.

## Settings

Setting | Default | Effect
--- | --- | ---
CPU usage, CPU temperature, RAM, swap, disk, download, upload | On | Show or hide each metric independently.
Category separators | On | Separate processor, memory, storage, and network groups.
Detailed tooltip | On | Show expanded metric names and values on hover.
Compact network units | On | Use `M/s`; disable it for `MB/s`-style labels.
Disk path | `/` | Select the filesystem whose utilization is displayed.

## Notes

- The plugin only reads snapshots exposed by Noctalia through `systemStats()` and `diskStats()`.
- It does not access the network, execute processes, read arbitrary files, or write data.
- Values refresh according to Noctalia's system-monitor sampling intervals; the widget redraws once per second.
- If every metric is disabled, the capsule remains accessible and prompts the user to enable a metric.

## Development

Repository knowledge and the current handoff follow Google Open Knowledge Format v0.2. Start at [`knowledge/index.md`](knowledge/index.md).

Run the dependency-free local check before publishing:

```sh
python3 scripts/validate_okf.py
```
