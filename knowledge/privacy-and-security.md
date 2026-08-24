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

Noctalia plugins are trusted user-owned code, but this plugin deliberately uses a narrow runtime surface. It reads only the aggregate snapshots returned by `systemStats()` and the root-disk snapshot returned by `diskStats("/")`.

The plugin does not:

- make network requests;
- execute subprocesses;
- read arbitrary files or environment variables;
- write persistent state;
- collect process names, command lines, usernames, hostnames, or file paths.

The public repository must not contain local usernames, machine names, home-directory paths, logs, environment files, or unsanitized screenshots. `thumbnail.webp` uses a privacy-clean Noctalia System capture containing generic performance metrics but no usernames, hostnames, paths, or other machine identifiers.

Run the local validator from [Local development](local-development.md) before publication. The validator checks the OKF structure, internal links, and common machine-specific data leaks. This check reduces accidental exposure but does not replace review of the complete Git diff before committing or pushing.
