# Project agent guide

This repository contains the `tmelik/system-monitor` Noctalia v5 plugin.

## Reading order

1. Read `README.md` for the public behavior and usage instructions.
2. Read `knowledge/index.md` and only the concepts relevant to the task.
3. Inspect `plugin.toml` and `widget.luau`, which are the implementation source of truth.

## Working rules

- Keep the plugin dependency-free and compatible with the declared plugin API.
- Do not add hostnames, local usernames, home-directory paths, logs, environment files, or unsanitized screenshots.
- Do not add network access, subprocess execution, arbitrary filesystem reads, or persistent writes without documenting the new trust boundary.
- Keep user-visible behavior in `README.md` and durable implementation knowledge in the OKF bundle synchronized with source changes.
- Preserve the compact single-capsule presentation and graceful `—` fallback for unavailable metrics unless a task explicitly changes that contract.

## Validation

Run before handing off a change:

```sh
python3 scripts/validate_okf.py
```

Also test the widget in a compatible Noctalia v5 session when runtime behavior changes.
