---
type: Handoff
title: Current implementation state
description: Verified status and the next publication steps for System Monitor 1.2.0.
tags: [handoff, status, release]
status: stable
sources:
  - resource: ../plugin.toml
  - resource: ../widget.luau
  - resource: ../README.md
  - resource: ../thumbnail.webp
---

# Current implementation state

Version `1.2.0` implements one dependency-free bar widget using plugin API 16. The widget has been exercised in Noctalia v5 beta.9 with all seven metrics visible in one capsule. Thin separators group processor, memory, storage, and network values. RAM uses the supported `server-2` glyph, disk uses `database`, and the default click action opens Control Center.

The manifest exposes per-instance controls for every metric plus separators, tooltip visibility, network-unit style, and disk path. Empty categories do not leave orphan separators, and disabling all metrics leaves a compact recovery prompt.

The publication package is licensed under GPL-3.0-only and includes its manifest, entry script, public README, English setting translations, generator-produced 960×540 WebP thumbnail based on a privacy-clean Noctalia System capture, agent guidance, and this OKF v0.2 bundle.

The source is published at `TMelik/noctalia-system-monitor`. The community-store package is submitted from branch `TMelik:add-system-monitor` in [noctalia-dev/community-plugins#460](https://github.com/noctalia-dev/community-plugins/pull/460); the remaining publication step is upstream review and merge.
