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

Optional GPU usage, temperature, and VRAM values form a group between CPU and memory; all three are disabled by default. Each value has its own glyph, but every value shares one bar capsule. Thin separators divide non-empty CPU, GPU, memory, storage, and network groups. Network values use decimal scaling, while absolute RAM/disk modes use compact binary units. Percentages and temperatures are rounded to whole numbers.

Widget settings let users hide each metric independently, omit unavailable values, control threshold highlighting and colors, hide separators, disable the tooltip, switch network labels between compact and explicit byte units, select an exact network interface, choose RAM/disk display modes, and select a different disk path. Whitespace is trimmed from interface names; an empty name means total non-loopback traffic, while an unknown name remains unavailable.

Separators are only inserted between non-empty categories. If every metric is disabled, the widget shows `No metrics`; if enabled metrics are all omitted as unavailable, it shows `No data`. With hiding disabled, unavailable individual metrics retain the honest `—` fallback and are never highlighted.

The default left-click action opens Control Center on its System tab. Users may override widget actions through ordinary Noctalia configuration. Middle-click opens the per-instance widget settings. Hovering shows a native two-column `{ key, value }` table in CPU, GPU, memory, storage, and network order. Only rendered metrics receive rows; CPU frequency and load are added whenever at least one CPU metric is rendered. RAM, swap, disk, and VRAM show percentage plus used and total amounts, without available amounts or sample age. The network row combines only the rendered RX/TX directions and follows `compact_network`. Aggregate traffic uses the shorter `Network` key to preserve value width; an exact interface keeps `Network (interface)`. Disabling the tooltip clears it completely.

See [Plugin architecture](plugin-architecture.md) for the data flow and [Privacy and security](privacy-and-security.md) for the runtime boundary.
