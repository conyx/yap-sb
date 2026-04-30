#!/usr/bin/env python3
"""Generate a single-file boxee.scad from main.scad.

Inlines all local include files (non-BOSL2) at the /* [Hidden] */ marker,
making the output self-contained for sharing on [MakerWorld/Thingvers/Printables]
platforms.
"""

import datetime
import re
import shutil
import subprocess
import sys
from pathlib import Path

PROJECT_NAME = "[boxee.scad] Parametric storage box created in OpenSCAD"
PROJECT_COPYRIGHT = "Copyright © 2026 by Conyx"
PROJECT_URL = "https://github.com/conyx/boxee.scad"
PROJECT_LICENCE = "CC BY-SA 4.0"
PROJECT_LICENCE_URL = "https://creativecommons.org/licenses/by-sa/4.0"

INCLUDE_RE = re.compile(r"^include\s*<([^>]+)>")
HIDDEN_MARKER = "/* [Hidden] */"


def git_short_commit():
    if not shutil.which("git") or not Path(".git").exists():
        return None
    try:
        out = subprocess.check_output(
            ["git", "rev-parse", "--short", "HEAD"],
            stderr=subprocess.DEVNULL,
        ).decode().strip()
    except subprocess.CalledProcessError:
        return None
    return out or None


def header():
    timestamp = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    lines = [
        f"// {PROJECT_NAME}",
        f"// {PROJECT_COPYRIGHT}",
        f"// Project repository: {PROJECT_URL}",
        f"// Licence: {PROJECT_LICENCE} ({PROJECT_LICENCE_URL})",
        f"// Generated: {timestamp}",
    ]
    commit = git_short_commit()
    if commit:
        lines.append(f"// Commit: {commit}")
    lines.append("")
    return lines


def inline(source):
    deferred = []
    body = []
    for line in source.read_text().splitlines():
        match = INCLUDE_RE.match(line)
        if match and not match.group(1).startswith("BOSL2/"):
            deferred.append(source.parent / match.group(1))
            continue
        body.append(line)
        if HIDDEN_MARKER in line:
            body.append("")
            for path in deferred:
                body.extend(path.read_text().splitlines())
                body.append("")
    return body


def main():
    source = Path(sys.argv[1])
    sys.stdout.write("\n".join(header() + inline(source)) + "\n")


if __name__ == "__main__":
    main()
