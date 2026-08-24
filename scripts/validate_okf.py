#!/usr/bin/env python3
"""Validate the repository-local OKF v0.2 bundle and publication hygiene."""

from __future__ import annotations

import getpass
import re
import socket
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
KNOWLEDGE = ROOT / "knowledge"
RESERVED = {"index.md", "log.md"}
VALID_STATUSES = {"stable", "draft", "deprecated"}
LINK_RE = re.compile(r"(?<!!)\[[^\]]+\]\(([^)]+)\)")
TOP_LEVEL_KEY_RE = re.compile(r"^([A-Za-z_][A-Za-z0-9_-]*):(?:\s*(.*))?$")
EMAIL_RE = re.compile(rb"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}")


def frontmatter(path: Path, text: str) -> tuple[dict[str, str], str]:
    lines = text.splitlines()
    if not lines or lines[0] != "---":
        raise ValueError("concept must start with YAML frontmatter")

    try:
        end = lines.index("---", 1)
    except ValueError as error:
        raise ValueError("frontmatter has no closing delimiter") from error

    values: dict[str, str] = {}
    for line in lines[1:end]:
        if not line or line[0].isspace() or line.startswith("-"):
            continue
        match = TOP_LEVEL_KEY_RE.match(line)
        if not match:
            continue
        key, value = match.groups()
        if key in values:
            raise ValueError(f"duplicate frontmatter key: {key}")
        values[key] = (value or "").strip().strip('"\'')

    return values, "\n".join(lines[end + 1 :])


def validate_links(path: Path, text: str, errors: list[str]) -> None:
    for target in LINK_RE.findall(text):
        clean = target.split("#", 1)[0].strip()
        if not clean or "://" in clean or clean.startswith(("#", "mailto:")):
            continue
        resolved = (path.parent / clean).resolve()
        if not resolved.is_relative_to(KNOWLEDGE.resolve()):
            errors.append(f"{path.relative_to(ROOT)}: link leaves knowledge bundle: {target}")
        elif not resolved.exists():
            errors.append(f"{path.relative_to(ROOT)}: broken local link: {target}")


def validate_privacy(errors: list[str]) -> None:
    local_user = getpass.getuser().encode().lower()
    local_host = socket.gethostname().encode().lower()
    home_markers = (b"/" + b"home" + b"/", b"/" + b"Users" + b"/")

    for path in ROOT.rglob("*"):
        if not path.is_file() or ".git" in path.parts:
            continue
        data = path.read_bytes()
        lowered = data.lower()
        relative = path.relative_to(ROOT)

        if any(marker.lower() in lowered for marker in home_markers):
            errors.append(f"{relative}: contains an absolute home-directory marker")
        if len(local_user) >= 4 and local_user in lowered:
            errors.append(f"{relative}: contains the current operating-system username")
        if len(local_host) >= 6 and local_host in lowered:
            errors.append(f"{relative}: contains the current hostname")
        if EMAIL_RE.search(data):
            errors.append(f"{relative}: contains an email address")


def main() -> int:
    errors: list[str] = []
    concepts = 0
    indexes = 0
    logs = 0

    root_index = KNOWLEDGE / "index.md"
    if not root_index.is_file():
        errors.append("knowledge/index.md is missing")
    elif 'okf_version: "0.2"' not in root_index.read_text(encoding="utf-8"):
        errors.append('knowledge/index.md must declare okf_version: "0.2"')

    for path in sorted(KNOWLEDGE.rglob("*.md")):
        relative = path.relative_to(ROOT)
        text = path.read_text(encoding="utf-8")
        validate_links(path, text, errors)

        if path.name == "index.md":
            indexes += 1
            continue
        if path.name == "log.md":
            logs += 1
            continue

        concepts += 1
        try:
            values, _body = frontmatter(path, text)
        except ValueError as error:
            errors.append(f"{relative}: {error}")
            continue

        if not values.get("type"):
            errors.append(f"{relative}: missing non-empty type")
        status = values.get("status")
        if status and status not in VALID_STATUSES:
            errors.append(f"{relative}: invalid status: {status}")
        if "sources:" in text and not re.search(r"^\s+- resource:\s+\S+", text, re.MULTILINE):
            errors.append(f"{relative}: sources must contain resource mappings")

    validate_privacy(errors)

    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        print(f"OKF check failed with {len(errors)} error(s).", file=sys.stderr)
        return 1

    print(
        "OKF check passed: "
        f"{concepts} concept(s), {indexes} index file(s), {logs} log file(s), "
        "privacy scan clean."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
