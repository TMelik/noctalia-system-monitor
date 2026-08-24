---
type: InterfaceContract
title: User-visible widget behavior
description: Stable presentation and interaction contracts for the System Summary capsule.
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

Each value has its own glyph, but every value shares one bar capsule. RAM uses the supported `server-2` glyph to remain visually distinct from CPU. Thin separators divide the sequence into processor, memory, storage, and network groups; receive and transmit rates remain together in the final group. Network values use decimal `B/s`, `k/s`, `M/s`, and `G/s` scaling by default. Percentages and temperature are rounded to whole numbers.

Widget settings let users hide each metric independently, hide category separators, disable the tooltip, switch network labels between compact and explicit byte units, and select a different disk path. Separators are only inserted between non-empty categories. If every metric is disabled, the widget renders a small settings prompt rather than disappearing completely.

The default left-click action opens Control Center on its System tab. Users may override widget actions through ordinary Noctalia configuration. Middle-click opens the per-instance widget settings. Hovering shows expanded names and values when the tooltip setting is enabled.

See [Plugin architecture](plugin-architecture.md) for the data flow and [Privacy and security](privacy-and-security.md) for the runtime boundary.
