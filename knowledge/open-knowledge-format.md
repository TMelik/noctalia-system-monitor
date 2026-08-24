---
type: SpecificationReference
title: Open Knowledge Format v0.2
description: Pinned upstream specification and the deliberately small local OKF profile.
tags: [okf, specification, knowledge]
status: stable
sources:
  - resource: https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/9a15b13ba996bb713b19e053ea744abee01c2714/okf/SPEC.md
---

# Open Knowledge Format v0.2

This bundle targets the Google Open Knowledge Format v0.2 specification at upstream commit `9a15b13ba996bb713b19e053ea744abee01c2714`.

The local profile uses:

- `okf_version: "0.2"` in the root `index.md`;
- reserved `index.md` and `log.md` files;
- one UTF-8 Markdown file with YAML frontmatter per concept;
- a non-empty `type` for every concept;
- structured `sources` entries with a `resource` field;
- lifecycle values `stable`, `draft`, or `deprecated`;
- ordinary relative Markdown links between concepts.

Source code remains authoritative. The knowledge bundle is a discovery and handoff layer, not generated runtime configuration, an execution system, or a replacement for tests.
