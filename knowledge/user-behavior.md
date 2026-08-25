---
type: InterfaceContract
title: User-visible widget behavior
description: Stable presentation and interaction contracts for the System Monitor capsule.
tags: [noctalia, bar, interface, metrics]
status: stable
sources:
  - resource: ../README.md
  - resource: ../plugin.toml
  - resource: ../widget.luau
---

# User-visible behavior

By default, the widget combines seven values in this order:

1. aggregate CPU usage;
2. CPU temperature;
3. RAM utilization;
4. swap utilization;
5. disk utilization for `/`;
6. aggregate receive rate;
7. aggregate transmit rate.

GPU usage, temperature, and VRAM values form a group between CPU and memory. Each of the three has its own `auto`/`on`/`off` setting, default `auto`: it auto-shows only when a GPU actually reports that specific field (usage needs `usagePercent`, temperature needs `tempC`, VRAM needs both used and total bytes), so a machine with no GPU — or an iGPU that only reports some fields — shows just what's actually available. `on`/`off` force the row regardless of data. Each value has its own glyph, but every value shares one bar capsule. Thin separators divide non-empty CPU, GPU, memory, storage, and network groups. Network values use decimal scaling, while absolute RAM/disk modes use compact binary units. Percentages and temperatures are rounded to whole numbers.

Widget settings let users hide each metric independently, omit unavailable values, control threshold highlighting and colors, hide separators, disable the tooltip or its top-process/CPU-details rows, switch network labels between compact and explicit byte units, select an exact network interface, choose RAM/disk display modes, and select a different disk path. Whitespace is trimmed from interface names; an empty name means total non-loopback traffic, while an unknown name remains unavailable.

Separators are only inserted between non-empty categories. If every metric is disabled, the widget shows `No metrics`; if enabled metrics are all omitted as unavailable, it shows `No data`. With hiding disabled, unavailable individual metrics retain the honest `—` fallback and are never highlighted.

The default left-click action opens Control Center on its System tab. Users may override widget actions through ordinary Noctalia configuration. Middle-click opens the per-instance widget settings. Hovering shows a native two-column `{ key, value }` table in CPU, GPU, memory, storage, and network order. Only rendered metrics receive rows. CPU usage, temperature, frequency, and load are opt-in tooltip rows via `show_cpu_details_in_tooltip` (default off), since the bar capsule already shows enabled CPU metrics; when enabled and Noctalia doesn't report CPU frequency itself, the widget falls back to reading it from the OS (sysfs, then `/proc/cpuinfo`) every five seconds. RAM, swap, disk, and VRAM show percentage plus used and total amounts, without available amounts or sample age. The `Network session` row combines only rendered RX/TX directions and shows totals accumulated in memory since the plugin runtime loaded; an exact interface is identified in the key. These estimates reset on plugin or Noctalia reload and are not system-uptime totals. When enabled, `Top CPU` and `Top RAM` follow at the end using short process names without command-line arguments. Disabling the tooltip clears it completely and stops process/frequency polling.

See [Plugin architecture](plugin-architecture.md) for the data flow and [Privacy and security](privacy-and-security.md) for the runtime boundary.
