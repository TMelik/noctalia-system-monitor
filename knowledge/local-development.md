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

For runtime testing, place the plugin where a Noctalia API 26+ development source can discover it, enable `tmelik/system-monitor`, and add `tmelik/system-monitor:summary` to a bar. Confirm the seven default values render, then cover the critical-threshold boundary and a custom critical color, every RAM/disk mode, aggregate/valid/unknown interfaces, RX-only and TX-only configurations, unavailable hiding, a long disk path, all three fallbacks, both bar orientations, tooltip on/off, and separator cleanup. Cover each GPU setting's `auto`/`on`/`off` modes against full, partial, and no GPU data. Verify Network session accumulation plus top-process disabled, first-poll, second-poll, command-failure, and unavailable-hiding states, and the CPU-details tooltip toggle off/on together with the CPU-frequency fallback's sysfs-success, sysfs-failure-then-proc-success, and total-failure paths. Confirm the aligned tooltip remains reasonably sized, left-click opens Control Center's System tab, and middle-click opens widget settings.

A quick way to exercise the update logic without a full Noctalia environment is a throwaway Lua 5.1 mock harness (see prior session transcripts for the pattern): stub `noctalia`/`ui`/`barWidget` as plain tables, `loadfile("widget.luau")()` once, then call the global `update()` repeatedly while mutating the mock's config/stats/`nowMs` to drive multi-poll scenarios (process and CPU-frequency polling both use module-local state that persists across `update()` calls, so disabling and re-enabling a poller — e.g. via its tooltip toggle — is the way to reset it between scenarios). Keep the harness in the scratchpad only; never commit it.

Before a community submission:

1. review every changed file and the synthetic thumbnail;
2. confirm `plugin.toml` uses an allowed ID, tags, semantic version, and the oldest required API level;
3. run the local validator;
4. run the upstream community repository checks after placing this directory at `system-monitor/`;
5. include a sanitized screenshot or short video in the pull-request description.

Do not edit the community repository's generated `catalog.toml`.
