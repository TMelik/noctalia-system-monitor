---
type: Handoff
title: Current implementation state
description: Implementation and verification state for System Monitor 1.5.2.
tags: [handoff, status, release]
status: stable
sources:
  - resource: ../plugin.toml
  - resource: ../widget.luau
  - resource: ../README.md
  - resource: ../thumbnail.webp
---

# Current implementation state

Version `1.5.2` implements one bar widget using plugin API 26 and the declared `ps` and `cat` dependencies. The default remains the original seven metrics in one capsule, with GPU usage, temperature, and VRAM inserted as a separate group whenever a GPU reports that field (`auto`/`on`/`off` per metric, default `auto`). RAM and disk support percentage, used, and available display modes; network rates can use aggregate traffic or an exact interface.

The manifest also exposes unavailable-value hiding, top-process visibility, and discrete activity/critical colors driven by effective global Noctalia thresholds. Metric and divider nodes use stable keys. Normal metric nodes leave `color` unset so a compatible Noctalia host supplies the standard widget foreground and icon colors, while activity and critical states explicitly override them. The host must restore those defaults when retained nodes leave a threshold state. Empty categories do not leave orphan separators. The three fallback states distinguish a missing system snapshot, all metrics disabled, and all enabled metrics hidden as unavailable. The normal tooltip is a native ordered two-column table limited to rendered metrics; amount rows show percentage and `used / total`. CPU usage, temperature, frequency, and load are opt-in tooltip rows (`show_cpu_details_in_tooltip`, default off) since the capsule already shows enabled CPU metrics; when enabled and Noctalia doesn't report CPU frequency, the widget falls back to reading it via `cat` from sysfs then `/proc/cpuinfo`. Network shows non-persistent RX/TX totals accumulated during the plugin runtime session, and default-enabled Top CPU/RAM rows use sanitized `ps` metadata.

The publication package is licensed under GPL-3.0-only and includes its manifest, entry script, public README, English setting translations, generator-produced 960×540 WebP thumbnail based on a privacy-clean Noctalia System capture, agent guidance, and this OKF v0.2 bundle.

The source is published at `TMelik/noctalia-system-monitor`. The prior community-store package was submitted in [noctalia-dev/community-plugins#460](https://github.com/noctalia-dev/community-plugins/pull/460). Version 1.5.2 is published for review in [community-plugins#651](https://github.com/noctalia-dev/community-plugins/pull/651), paired with the Noctalia host fix in [noctalia#4318](https://github.com/noctalia-dev/noctalia/pull/4318). Both PR branches are pushed and #651 is ready for review; its release must not precede the required host support.

The host change passed its focused reconciler test, the complete 112-test suite, and a debug build. A live Niri check used separate bright fixed values for widget foreground and icon color with highlighting disabled: labels and glyphs followed their respective settings, font weight remained inherited, and explicit activity/critical colors remained plugin overrides. The test build was then stopped and the installed Noctalia 5.0.1 package was restored. Community issue [#634](https://github.com/noctalia-dev/community-plugins/issues/634) contains the user-facing explanation, links to both PRs, and the requested reporter/developer mentions.
