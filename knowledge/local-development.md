---
type: Runbook
title: Local development and validation
description: How to validate and prepare the plugin for Noctalia community review.
tags: [development, validation, release]
status: stable
sources:
  - resource: ../README.md
  - resource: ../scripts/validate_okf.py
  - resource: https://github.com/noctalia-dev/community-plugins/blob/main/README.md
---

# Local development and validation

Run the repository-local knowledge and privacy check:

```sh
python3 scripts/validate_okf.py
```

For runtime testing, place the plugin where a Noctalia API 26+ development source can discover it, enable `tmelik/system-monitor`, and add `tmelik/system-monitor:summary` to a bar. Confirm the seven default values render with GPU hidden, then cover threshold boundaries and custom colors, every RAM/disk mode, aggregate/valid/unknown interfaces, RX-only and TX-only configurations, partial GPU data, unavailable hiding, a long disk path, all three fallbacks, both bar orientations, tooltip on/off, and separator cleanup. Verify that the normal tooltip is an aligned two-column table in CPU-to-network order and remains reasonably sized. Confirm left-click opens Control Center's System tab and middle-click opens widget settings.

Before a community submission:

1. review every changed file and the synthetic thumbnail;
2. confirm `plugin.toml` uses an allowed ID, tags, semantic version, and the oldest required API level;
3. run the local validator;
4. run the upstream community repository checks after placing this directory at `system-monitor/`;
5. include a sanitized screenshot or short video in the pull-request description.

Do not edit the community repository's generated `catalog.toml`.
