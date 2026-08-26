---
type: Handoff
title: Current implementation state
description: Implementation and verification state for System Monitor 1.5.1.
tags: [handoff, status, release]
status: stable
sources:
  - resource: ../plugin.toml
  - resource: ../widget.luau
  - resource: ../README.md
  - resource: ../thumbnail.webp
---

# Current implementation state

Version `1.5.1` implements one bar widget using plugin API 26 and the declared `ps` and `cat` dependencies. The default remains the original seven metrics in one capsule, with GPU usage, temperature, and VRAM inserted as a separate group whenever a GPU reports that field (`auto`/`on`/`off` per metric, default `auto`). RAM and disk support percentage, used, and available display modes; network rates can use aggregate traffic or an exact interface.

The manifest also exposes unavailable-value hiding, top-process visibility, and discrete activity/critical colors driven by effective global Noctalia thresholds. Metric and divider nodes use stable keys, and normal values explicitly restore `on_surface`, so retained declarative nodes cannot leak divider or prior threshold colors when auto-detected rows appear or disappear. Empty categories do not leave orphan separators. The three fallback states distinguish a missing system snapshot, all metrics disabled, and all enabled metrics hidden as unavailable. The normal tooltip is a native ordered two-column table limited to rendered metrics; amount rows show percentage and `used / total`. CPU usage, temperature, frequency, and load are opt-in tooltip rows (`show_cpu_details_in_tooltip`, default off) since the capsule already shows enabled CPU metrics; when enabled and Noctalia doesn't report CPU frequency, the widget falls back to reading it via `cat` from sysfs then `/proc/cpuinfo`. Network shows non-persistent RX/TX totals accumulated during the plugin runtime session, and default-enabled Top CPU/RAM rows use sanitized `ps` metadata.

The publication package is licensed under GPL-3.0-only and includes its manifest, entry script, public README, English setting translations, generator-produced 960×540 WebP thumbnail based on a privacy-clean Noctalia System capture, agent guidance, and this OKF v0.2 bundle.

The source is published at `TMelik/noctalia-system-monitor`. The prior community-store package was submitted from branch `TMelik:add-system-monitor` in [noctalia-dev/community-plugins#460](https://github.com/noctalia-dev/community-plugins/pull/460). Version 1.5.1 passes repository validation and the color-regression mock; graphical bar-capsule verification must use a compatible Noctalia v5 session. Publication still requires an explicit commit and push.
