#!/usr/bin/env python3
"""Render Argo CD project/application templates with the CD repository URL."""

from __future__ import annotations

import argparse
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--template-dir", required=True, type=Path)
    parser.add_argument("--output-dir", required=True, type=Path)
    parser.add_argument("--repo-url", required=True)
    args = parser.parse_args()

    args.output_dir.mkdir(parents=True, exist_ok=True)

    template_names = ["project.yaml.tpl", "application.yaml.tpl"]

    for template_name in template_names:
        source = args.template_dir / template_name
        if not source.is_file():
            raise FileNotFoundError(source)

        rendered = source.read_text(encoding="utf-8").replace(
            "__CD_REPO_URL__", args.repo_url
        )

        destination = args.output_dir / template_name.removesuffix(".tpl")
        destination.write_text(rendered, encoding="utf-8")
        print(f"[OK] Rendered: {destination}")


if __name__ == "__main__":
    main()
