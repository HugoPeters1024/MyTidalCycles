#!/usr/bin/env python3
"""Regenerate strudel.json from tracked and unignored sample files."""

import json
import re
import subprocess
from collections import defaultdict
from pathlib import Path
from urllib.parse import quote


ROOT = Path(__file__).resolve().parent
BASE_URL = "https://raw.githubusercontent.com/HugoPeters1024/MyTidalCycles/master/"
EXTENSIONS = {".wav", ".mp3", ".ogg", ".opus", ".flac", ".aif", ".aiff", ".m4a"}
COLLECTIONS = {"extra", "tidalclub", "VintageDrums"}


def main():
    result = subprocess.check_output(
        ["git", "ls-files", "--cached", "--others", "--exclude-standard", "-z"],
        cwd=ROOT,
    )
    files = sorted(set(result.decode("utf-8").split("\0")) - {""})
    banks = defaultdict(list)
    parents = {}
    for filename in files:
        path = Path(filename)
        if path.suffix.lower() not in EXTENSIONS or not (ROOT / path).is_file():
            continue
        parts = path.parent.parts
        if parts and parts[0] in COLLECTIONS:
            parts = parts[1:]
        name = re.sub(r"[^a-z0-9_]+", "_", "_".join(parts).lower()).strip("_")
        name = name or "samples"
        if name in parents and parents[name] != path.parent:
            raise ValueError(
                f"Bank name {name!r} is shared by {parents[name]} and {path.parent}"
            )
        parents[name] = path.parent
        banks[name].append(quote(path.as_posix(), safe="/"))

    manifest = {"_base": BASE_URL, **dict(sorted(banks.items()))}
    target = ROOT / "strudel.json"
    target.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    count = sum(len(samples) for samples in banks.values())
    print(f"Wrote {target.name}: {count:,} samples in {len(banks)} banks.")


if __name__ == "__main__":
    main()
