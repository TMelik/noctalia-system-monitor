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

`plugin.toml` declares one bar-widget entry, `tmelik/system-monitor:summary`, at plugin API 26. API 26 is required because the widget reads effective global threshold settings with `noctalia.getSetting()`.

`widget.luau` runs in Noctalia's plugin VM and redraws once per second. Noctalia's system-monitor service owns the actual sampling cadence, so redraws may legitimately reuse the latest sample.

The update flow is:

1. Read per-instance display settings and the aggregate snapshot with `noctalia.systemStats()`.
2. Read every global activity/critical threshold pair under `system.monitor`, falling back to Noctalia defaults when a pair is invalid.
3. Select aggregate or exact-interface network rates, integrate each new sampled interval into in-memory session totals, and opt the configured disk path into `diskStats()` sampling.
4. When top processes are enabled, poll `ps` asynchronously every five seconds without overlapping calls and derive the top CPU/RAM consumers.
5. Resolve each GPU row's `auto`/`on`/`off` setting against whether Noctalia's snapshot actually reports that field (`usagePercent`, `tempC`, or both VRAM byte fields), then derive swap and VRAM percentages plus RAM/disk used and available amounts.
6. When CPU details are shown in the tooltip and Noctalia doesn't report `cpu.freqMhz`, poll a CPU-frequency fallback asynchronously every five seconds (sysfs `scaling_cur_freq`, then `/proc/cpuinfo`) without overlapping calls.
7. Render available glyph/label pairs in CPU, GPU, memory, storage, network order inside one orientation-aware capsule.
8. Publish an ordered two-column tooltip as `{ key, value }` rows for metrics that were actually rendered, followed by optional CPU-detail and process rows.

Threshold coloring is discrete: regular below activity, the configured activity color below critical, and the configured critical color at critical or above. Network values are converted to decimal MB/s for comparison; RAM and disk always use utilization percentages even when their labels show absolute amounts.

Every metric glyph/label pair and category divider has a stable declarative UI key. The regular `on_surface` color is applied explicitly below the activity threshold, preventing Noctalia's retained UI nodes from carrying a prior highlight or divider color across threshold and auto-detection changes.

Missing snapshots or individual sensors never become a misleading zero. Depending on settings, individual unavailable values display `—` or are omitted. Dedicated `System data unavailable`, `No metrics`, and `No data` fallbacks preserve access to the capsule.

The tooltip follows the same CPU, GPU, memory, storage, and network ordering as the capsule. CPU usage, temperature, frequency, and load are opt-in via `show_cpu_details_in_tooltip` (default off) and appear together whenever enabled and at least one CPU metric is rendered. VRAM, RAM, swap, and disk values combine utilization with `used / total`. Network combines only enabled and rendered RX/TX directions, but shows compact binary session totals rather than duplicating the live rates.

Network totals are derived only when `sampledAtMs` advances: the current sampled rate is multiplied by the elapsed sample interval, preventing repeated redraws of one snapshot from being counted more than once. Aggregate and per-interface counters remain in Luau memory, start at zero on runtime load, and reset on plugin or Noctalia reload. They are estimates for the plugin session, not persistent system-uptime counters.

Process monitoring first uses `ps -eo pid:1=,rss:1=,cputimes:1=` and then requests `comm` only for the selected PID or PIDs, with a two-second timeout per command. This keeps every visible process in CPU/RAM candidate selection while keeping each result below the runtime output cap. CPU utilization is calculated from CPU-time deltas between successful polls, so one fully occupied core is 100% and multithreaded processes may exceed 100%. RAM uses current RSS. The first successful poll can identify Top RAM; Top CPU requires a second poll. Failed, truncated, overlapping, malformed, or stale results never block the widget and use the ordinary unavailable behavior.

The CPU-frequency fallback only ever runs when `show_cpu_details_in_tooltip` and the tooltip are both enabled and Noctalia's own snapshot has no `cpu.freqMhz`. It first reads `/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq` (kHz) via `cat`; on failure it falls back to parsing the first `cpu MHz` line out of `/proc/cpuinfo`. Both commands share the same two-second timeout and five-second, non-overlapping poll cadence as process monitoring. A missing `cat`, a failed command, or unparsable output all resolve to the same `—` fallback as before — Noctalia's own value, when present, is always preferred and skips the shell call entirely.
