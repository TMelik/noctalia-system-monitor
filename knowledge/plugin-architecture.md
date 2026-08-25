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
3. Select aggregate or exact-interface network rates and opt the configured disk path into `diskStats()` sampling.
4. Derive swap and VRAM percentages plus RAM/disk used and available amounts.
5. Render available glyph/label pairs in CPU, GPU, memory, storage, network order inside one orientation-aware capsule.
6. Publish an ordered two-column tooltip as `{ key, value }` rows for metrics that were actually rendered.

Threshold coloring is discrete: regular below activity, the configured activity color below critical, and the configured critical color at critical or above. Network values are converted to decimal MB/s for comparison; RAM and disk always use utilization percentages even when their labels show absolute amounts.

Missing snapshots or individual sensors never become a misleading zero. Depending on settings, individual unavailable values display `—` or are omitted. Dedicated `System data unavailable`, `No metrics`, and `No data` fallbacks preserve access to the capsule.

The tooltip follows the same CPU, GPU, memory, storage, and network ordering as the capsule. CPU frequency/load are contextual rows whenever either CPU metric is rendered. VRAM, RAM, swap, and disk values combine utilization with `used / total`; network combines only enabled and rendered RX/TX directions. Fallback tooltips remain plain explanatory strings.
