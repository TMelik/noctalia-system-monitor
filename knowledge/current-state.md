---
type: Handoff
title: Current implementation state
description: Implementation and verification state for System Monitor 1.3.0.
tags: [handoff, status, release]
status: stable
sources:
  - resource: ../plugin.toml
  - resource: ../widget.luau
  - resource: ../README.md
  - resource: ../thumbnail.webp
---

# Current implementation state

Version `1.3.0` implements one dependency-free bar widget using plugin API 26. The default remains the original seven metrics in one capsule, with optional GPU usage, temperature, and VRAM inserted as a separate group when enabled. RAM and disk support percentage, used, and available display modes; network rates can use aggregate traffic or an exact interface.

The manifest also exposes unavailable-value hiding and discrete activity/critical colors driven by effective global Noctalia thresholds. Empty categories do not leave orphan separators. The three fallback states distinguish a missing system snapshot, all metrics disabled, and all enabled metrics hidden as unavailable. The normal tooltip is a native ordered two-column table limited to rendered metrics; amount rows show percentage and `used / total`, and CPU frequency/load remain available whenever CPU is represented.

The publication package is licensed under GPL-3.0-only and includes its manifest, entry script, public README, English setting translations, generator-produced 960×540 WebP thumbnail based on a privacy-clean Noctalia System capture, agent guidance, and this OKF v0.2 bundle.

The source is published at `TMelik/noctalia-system-monitor`. The prior community-store package was submitted from branch `TMelik:add-system-monitor` in [noctalia-dev/community-plugins#460](https://github.com/noctalia-dev/community-plugins/pull/460). Version 1.3.0 passes repository OKF validation, the Noctalia offline plugin linter, and mock-runtime behavior checks. The structured tooltip also loaded successfully from the local override in a graphical Noctalia v5/API 26 session; its two columns were aligned and compact at the default settings.
