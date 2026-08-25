---
type: SecurityBoundary
title: Privacy and security boundary
description: What the plugin can access and what must never enter the public repository.
tags: [privacy, security, publication]
status: stable
sources:
  - resource: ../AGENTS.md
  - resource: ../plugin.toml
  - resource: ../widget.luau
  - resource: ../.gitignore
---

# Privacy and security boundary

Noctalia plugins are trusted user-owned code, but this plugin deliberately uses a narrow runtime surface. It reads aggregate snapshots returned by `systemStats()`, one user-configured disk snapshot returned by `diskStats(path)`, and the effective global `system.monitor` critical threshold values returned by `getSetting()`. When top-process display is enabled, it also invokes the declared `ps` dependency every five seconds. When CPU details are shown in the tooltip and Noctalia doesn't report CPU frequency itself, it invokes the declared `cat` dependency every five seconds against two fixed, hardcoded paths — never a user-supplied or otherwise variable path.

The plugin does not:

- make network requests;
- read any file path other than the two fixed CPU-frequency paths below, or read environment variables;
- write persistent state;
- collect command lines, process arguments, usernames, hostnames, or unrelated file paths.

The `ps` query requests only PID, short process name (`comm`), RSS, and accumulated CPU time across all visible processes. Names are sanitized before presentation and are never logged or persisted. The `cat` fallback only ever reads `/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq` and, if that fails, `/proc/cpuinfo`; only the first `cpu MHz` value is parsed out of the latter, everything else in its output is discarded. The configured disk path and network interface name are used only for Noctalia snapshot selection and tooltip presentation. Estimated network session totals are held only in Luau memory. None of these values are sent elsewhere.

The public repository must not contain local usernames, machine names, home-directory paths, logs, environment files, or unsanitized screenshots. `thumbnail.webp` uses a privacy-clean Noctalia System capture containing generic performance metrics but no usernames, hostnames, paths, or other machine identifiers.

Run the local validator from [Local development](local-development.md) before publication. The validator checks the OKF structure, internal links, and common machine-specific data leaks. This check reduces accidental exposure but does not replace review of the complete Git diff before committing or pushing.
