#!/usr/bin/env python3
""" Apply rounded corners to images.

    Near-square images are scaled to 600x600 (2% W/H tolerance).
    Other images are scaled to a width of 720 while preserving aspect ratio.
"""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path


SQUARE_SIZE = 600
NON_SQUARE_WIDTH = 720
SQUARE_TOLERANCE = 0.02
CORNER_RADIUS = 50
MARKER_SUFFIX_PATTERN = re.compile(r"_\d+[xX]\d+$")
REPO_ROOT = None
ASSETS_IMAGES_DIR = None
IMAGE_EXTENSIONS = {".png", ".jpg", ".jpeg", ".webp", ".gif", ".bmp", ".tiff"}

_corner_radius = None  # Set by main() from args.radius


def _find_repo_root() -> Path:
    current_dir = Path('.').resolve()
    try:
        output = subprocess.check_output(
            ["git", "rev-parse", "--show-toplevel"],
            cwd=current_dir,
            stderr=subprocess.DEVNULL,
            text=True,
        ).strip()
        if output:
            return Path(output)
    except (OSError, subprocess.CalledProcessError):
        pass
    return Path(__file__).resolve().parents[2]


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Scale near-square images to 600x600 (2% tolerance), "
            "others to width 720 while preserving aspect ratio, and apply rounded corners."
        )
    )
    parser.add_argument(
        "image_paths",
        nargs="*",
        type=Path,
        help="Image file paths to process.",
    )
    parser.add_argument(
        "-n",
        "--dry-run",
        action="store_true",
        help="Validate and report actions without writing output files.",
    )
    parser.add_argument(
        "-i",
        "--in-place",
        action="store_true",
        help="Overwrite input files instead of writing new suffixed files.",
    )
    parser.add_argument(
        "-p",
        "--pick",
        action="store_true",
        help="Interactively pick images from assets/images that do not have a _WxH sibling yet.",
    )
    parser.add_argument(
        "-s",
        "--size",
        type=str,
        default=None,
        help="Override default size: N (square size), WxH (explicit), or W (non-square width).",
    )
    parser.add_argument(
        "-r",
        "--radius",
        type=int,
        default=None,
        help="Corner radius for rounded corners (default: auto, max 50 or half the shortest side)",
    )
    return parser.parse_args(argv)


def _has_marker_in_name(image_path: Path) -> bool:
    return bool(MARKER_SUFFIX_PATTERN.search(image_path.stem))


def _is_nearly_square(width: int, height: int) -> bool:
    if width <= 0 or height <= 0:
        return False
    ratio = width / height
    return (1 - SQUARE_TOLERANCE) <= ratio <= (1 + SQUARE_TOLERANCE)


def _scaled_dimensions(width: int, height: int, size_override: str | None = None) -> tuple[int, int]:
    if width <= 0 or height <= 0:
        raise ValueError("Image dimensions must be positive")

    if size_override:
        # Accepts: '800', '800x600', '800X600'
        if 'x' in size_override.lower():
            w_str, h_str = re.split(r"[xX]", size_override)
            try:
                ow, oh = int(w_str), int(h_str)
                return ow, oh
            except Exception:
                raise ValueError(f"Invalid --size value: {size_override}")
        else:
            try:
                o = int(size_override)
            except Exception:
                raise ValueError(f"Invalid --size value: {size_override}")
            # If image is nearly square, use o x o, else o as width
            if _is_nearly_square(width, height):
                return o, o
            else:
                target_width = o
                target_height = max(1, round(height * (target_width / width)))
                return target_width, target_height

    # For nearly square images
    if _is_nearly_square(width, height):
        if width < SQUARE_SIZE or height < SQUARE_SIZE:
            return width, height
        return SQUARE_SIZE, SQUARE_SIZE

    # For non-square images
    target_width = NON_SQUARE_WIDTH
    target_height = max(1, round(height * (target_width / width)))
    if width < target_width or height < target_height:
        return width, height
    return target_width, target_height


def _scaled_marker(target_width: int, target_height: int) -> str:
    return f"_{target_width}x{target_height}"


def _has_marker_sibling(image_path: Path) -> bool:
    try:
        from PIL import Image
    except ImportError:
        return False

    try:
        with Image.open(image_path) as img:
            target_width, target_height = _scaled_dimensions(*img.size)
    except Exception:
        return False

    return _marker_output_path(image_path, target_width, target_height).is_file()


def _pick_candidates(images_dir: Path) -> list[Path]:
    if not images_dir.exists() or not images_dir.is_dir():
        return []

    candidates: list[Path] = []
    for path in sorted(images_dir.iterdir()):
        if not path.is_file():
            continue
        if path.suffix.lower() not in IMAGE_EXTENSIONS:
            continue
        if _has_marker_in_name(path):
            continue
        if _has_marker_sibling(path):
            continue
        candidates.append(path)
    return candidates


def _interactive_pick(candidates: list[Path]) -> list[Path]:
    if not candidates:
        print(f"[INFO] No pickable images found in {ASSETS_IMAGES_DIR}")
        return []

    try:
        from pick import Picker
    except ImportError:
        print("[ERROR] The pick package is required for --pick. Install with: pip install pick")
        return []

    options: list[str] = []
    for candidate in candidates:
        if candidate.is_relative_to(REPO_ROOT):
            options.append(str(candidate.relative_to(REPO_ROOT)))
        else:
            options.append(str(candidate))

    picker = Picker(
        options,
        "Select images to process (all preselected; space to toggle, enter to confirm, q to cancel)",
        multiselect=True,
        min_selection_count=0,
    )
    picker.selected_indexes = list(range(len(options)))
    selections = picker.start()
    return [candidates[index] for _, index in selections]


def _collect_image_paths(args: argparse.Namespace) -> list[Path]:
    collected: list[Path] = list(args.image_paths)
    if args.pick:
        collected.extend(_interactive_pick(_pick_candidates(ASSETS_IMAGES_DIR)))

    seen: set[Path] = set()
    deduped: list[Path] = []
    for path in collected:
        resolved = path.resolve()
        if resolved in seen:
            continue
        seen.add(resolved)
        deduped.append(path)
    return deduped


def _marker_output_path(image_path: Path, target_width: int, target_height: int) -> Path:
    marker = _scaled_marker(target_width, target_height)
    if image_path.suffix:
        return image_path.with_name(f"{image_path.stem}{marker}.png")
    return image_path.with_name(f"{image_path.name}{marker}")


def process_image(image_path: Path, dry_run: bool, in_place: bool, size_override: str | None = None) -> int:
    if not image_path.exists():
        print(f"[ERROR] Not found: {image_path}")
        return 1
    if not image_path.is_file():
        print(f"[ERROR] Not a file: {image_path}")
        return 1

    try:
        from PIL import Image, ImageDraw
    except ImportError:
        print("[ERROR] Pillow is required. Install with: pip install Pillow")
        return 1

    try:
        with Image.open(image_path) as img:
            width, height = img.size
            target_width, target_height = _scaled_dimensions(width, height, size_override)

            output_path = (
                image_path
                if in_place
                else _marker_output_path(image_path, target_width, target_height)
            )

            # Use global _corner_radius if set, else default logic
            corner_radius = _corner_radius
            if corner_radius is None:
                corner_radius = min(CORNER_RADIUS, target_width // 2, target_height // 2)
            else:
                corner_radius = max(1, min(corner_radius, target_width // 2, target_height // 2))

            if dry_run:
                print(
                    f"[DRY-RUN] Would process {image_path} "
                    f"({width}x{height} -> {target_width}x{target_height}, radius={corner_radius}) "
                    f"-> {output_path}"
                )
                return 0

            scaled = img.convert("RGBA").resize(
                (target_width, target_height),
                Image.Resampling.LANCZOS,
            )

            mask = Image.new("L", (target_width, target_height), 0)
            draw = ImageDraw.Draw(mask)
            draw.rounded_rectangle(
                xy=(0, 0, target_width - 1, target_height - 1),
                radius=corner_radius,
                fill=255,
            )

            scaled.putalpha(mask)
            scaled.save(output_path)
            print(f"[OK] Processed {image_path}"
                  f" -> {output_path.relative_to(image_path.parent)}")
            return 0
    except Exception as exc:
        print(f"[ERROR] Failed for {image_path}: {exc}")
        return 1


def main(argv: list[str] | None = None) -> int:
    global _corner_radius
    args = parse_args(argv)
    _corner_radius = args.radius
    image_paths = _collect_image_paths(args)
    if not image_paths:
        print("[ERROR] No images selected. Pass image paths or use --pick.")
        return 2

    exit_code = 0
    for image_path in image_paths:
        result = process_image(
            image_path,
            dry_run=args.dry_run,
            in_place=args.in_place,
            size_override=args.size,
        )
        if result != 0:
            exit_code = 1
    return exit_code

if __name__ == "__main__":
    REPO_ROOT = _find_repo_root()
    ASSETS_IMAGES_DIR = REPO_ROOT / "assets" / "images"
    sys.exit(main())
