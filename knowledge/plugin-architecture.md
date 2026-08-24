---
type: Architecture
title: System Monitor plugin architecture
description: How the bar widget obtains, formats, and renders Noctalia system statistics.
tags: [noctalia, plugin, architecture, system-monitor]
status: stable
sources:
  - resource: ../plugin.toml
  - resource: ../widget.luau
---

# Plugin architecture

`plugin.toml` declares one bar-widget entry, `tmelik/system-monitor:summary`, at plugin API 16. API 16 is the oldest level that provides both aggregate system snapshots and disk statistics.

`widget.luau` runs in Noctalia's plugin VM and redraws once per second. Noctalia's system-monitor service owns the actual sampling cadence, so redraws may legitimately reuse the latest sample.

The update flow is:

1. Read the aggregate snapshot with `noctalia.systemStats()`.
2. Opt the root filesystem into disk sampling with `noctalia.diskStats("/")`.
3. Calculate swap utilization from used and total MiB.
4. Format percentages, temperature, and decimal network rates.
5. Render glyph/label pairs inside one `ui.row` or `ui.column`, depending on bar orientation.
6. Publish a multiline tooltip containing expanded metric names.

Missing snapshots or individual sensors never become a misleading zero. The widget displays `—`, while a completely unavailable system monitor produces one explanatory fallback label.
