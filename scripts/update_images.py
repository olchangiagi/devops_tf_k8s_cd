#!/usr/bin/env python3
"""Update WEB_IMAGE and WAS_IMAGE entries in a Kustomize overlay."""

from __future__ import annotations

import argparse
import re
from pathlib import Path


def update_image_block(text: str, logical_name: str, new_name: str, new_tag: str) -> str:
    pattern = re.compile(
        rf"(?ms)(^[ \t]*-[ \t]+name:[ \t]*{re.escape(logical_name)}[ \t]*\r?\n"
        rf"[ \t]+newName:[ \t]*)([^\r\n]+)"
        rf"(\r?\n[ \t]+newTag:[ \t]*)([^\r\n]+)"
    )

    replacement = rf"\g<1>{new_name}\g<3>{new_tag}"
    updated, count = pattern.subn(replacement, text, count=1)

    if count != 1:
        raise ValueError(f"{logical_name} image block을 정확히 1개 찾지 못했습니다.")

    return updated


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--file", required=True, type=Path)
    parser.add_argument("--web-image", required=True)
    parser.add_argument("--was-image", required=True)
    parser.add_argument("--tag", required=True)
    args = parser.parse_args()

    if not args.file.is_file():
        raise FileNotFoundError(args.file)

    text = args.file.read_text(encoding="utf-8")
    text = update_image_block(text, "WEB_IMAGE", args.web_image, args.tag)
    text = update_image_block(text, "WAS_IMAGE", args.was_image, args.tag)
    args.file.write_text(text, encoding="utf-8")

    print(f"[OK] WEB image: {args.web_image}:{args.tag}")
    print(f"[OK] WAS image: {args.was_image}:{args.tag}")


if __name__ == "__main__":
    main()
