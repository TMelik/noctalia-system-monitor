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

For runtime testing, place the plugin where a Noctalia development source can discover it, enable `tmelik/system-monitor`, and add `tmelik/system-monitor:summary` to a bar. Confirm all seven values render, unavailable sensors show `—`, the tooltip is readable, and left-click opens Control Center's System tab.

Before a community submission:

1. review every changed file and the synthetic thumbnail;
2. confirm `plugin.toml` uses an allowed ID, tags, semantic version, and the oldest required API level;
3. run the local validator;
4. run the upstream community repository checks after placing this directory at `system-monitor/`;
5. include a sanitized screenshot or short video in the pull-request description.

Do not edit the community repository's generated `catalog.toml`.
