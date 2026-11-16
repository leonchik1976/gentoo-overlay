#!/usr/bin/env python3
"""Inventory the historical gentoo-artwork distfiles without extracting them.

This records evidence and uncertainty, not a determination of legal clearance.
Pillow is needed for image metadata inspection only, not by the ebuild.
"""

import argparse
import bz2
import collections
import csv
import gzip
import hashlib
import io
import json
import lzma
from pathlib import Path
import re
import tarfile

from PIL import Image


ARCHIVES = {
    "gentoo-artwork-0.2.tar.bz2": "c0",
    "gentoo-artwork-0.3.tar.bz2": "8f",
    "gentoo-artwork-0.4.tar.bz2": "18",
    "gentoo-artwork-0.4.1.tar.bz2": "56",
    "gentoo-artwork-0.4.2.tar.bz2": "89",
    "gentoo-bubble-icons-20060811.tar.gz": "da",
}
LICENSE_WORDS = re.compile(
    r"licen[cs]e|copyright|creative.?commons|\bGPL\b|rights reserved", re.I
)
REVIEW_NAMES = re.compile(
    r"leaf|ute-|larry|cow|tux|kde|gnome|mozilla|firefox|thunderbird|"
    r"windows|winword|winamp|kazaa|realplayer|nero|logitech|quake|doom|"
    r"duke|mario|sonic|diablo|starcraft|warcraft|broken.sword|monkey|"
    r"gentoo|adobe|photoshop|acrobat|opera|skype|icq|aim|yahoo",
    re.I,
)
KNOWN_REMOVED = {
    "gentoo-blue-leaf-1024x768.jpg",
    "gentoo-blue-ute-1024x768.jpg",
}


def digest(data):
    return hashlib.sha256(data).hexdigest()


def snippets(text):
    return sorted({
        text[max(0, m.start() - 60):m.end() + 200].replace("\x00", " ")
        for m in LICENSE_WORDS.finditer(text)
    })


def metadata(data, name):
    """Inspect text, PNG text (including compressed text), JPEG EXIF/comments,
    SVG/XML, XCF printable strings and gzip-compressed XPM content.
    No image pixels are decoded into a public preview.
    """
    result = {"dimensions": "", "metadata": {}, "license_hits": [], "error": ""}
    if name.endswith(".gz"):
        data = gzip.decompress(data)
        name = name[:-3]
    if name.lower().endswith((".svg", ".txt", ".kcsrc", ".xpm")) or Path(name).suffix == "":
        text = data.decode("utf-8", "replace")
        result["license_hits"] = snippets(text)
        if len(data) < 10000:
            result["metadata"]["text"] = text
        return result
    try:
        with Image.open(io.BytesIO(data)) as image:
            result["dimensions"] = f"{image.width}x{image.height}"
            # Accessing text also processes PNG text after the IDAT chunks.
            info = dict(image.info)
            info.update(getattr(image, "text", {}))
            for key, value in info.items():
                if key in ("icc_profile", "exif"):
                    continue
                if isinstance(value, bytes):
                    value = value.decode("utf-8", "replace")
                result["metadata"][str(key)] = str(value)
            for key, value in image.getexif().items():
                result["metadata"][f"EXIF:{key}"] = str(value)
    except Exception as exc:
        result["error"] = re.sub(r"0x[0-9a-fA-F]+", "<address>", f"{type(exc).__name__}: {exc}")
    if name.lower().endswith(".xcf"):
        result["metadata"]["printable_strings"] = "\n".join(
            s.decode("latin1") for s in re.findall(rb"[\x20-\x7e]{8,}", data)
        )
    result["license_hits"] = snippets("\n".join(result["metadata"].values()))
    return result


def write_csv(path, rows, fields):
    with path.open("w", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--distdir", type=Path, required=True)
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--image", type=Path, required=True,
                        help="image staged with all six USE flags enabled")
    parser.add_argument("--output-dir", type=Path, required=True)
    args = parser.parse_args()
    if not args.image.is_dir() or not any(args.image.rglob("*")):
        parser.error("--image must be a readable, non-empty staged image")
    args.output_dir.mkdir(parents=True, exist_ok=True)
    expected = {}
    for line in args.manifest.read_text().splitlines():
        fields = line.split()
        if fields and fields[0] == "DIST":
            expected[fields[1]] = (int(fields[2]), dict(zip(fields[3::2], fields[4::2])))

    rows, archive_results, metadata_results = [], [], []
    credits = collections.defaultdict(set)
    # Read attribution hints separately; a filename match is not proof of authorship.
    with tarfile.open(args.distdir / "gentoo-artwork-0.3.tar.bz2") as archive:
        text = archive.extractfile("gentoo-artwork-0.3/pixmaps/CREDITS").read().decode()
        author = ""
        for line in text.splitlines():
            if line and not line[0].isspace() and line.endswith(":"):
                author = line[:-1]
            elif line.startswith("\t") and author:
                credits[line.strip()].add(author)

    for filename, shard in ARCHIVES.items():
        data = (args.distdir / filename).read_bytes()
        size, hashes = expected[filename]
        matched = len(data) == size and all(
            hashlib.new(algorithm.lower(), data).hexdigest() == value
            for algorithm, value in hashes.items()
        )
        if not matched:
            raise SystemExit(f"Manifest mismatch: {filename}")
        url = f"https://distfiles.gentoo.org/distfiles/{shard}/{filename}"
        archive_rows = []
        with tarfile.open(fileobj=io.BytesIO(data)) as archive:
            for index, member in enumerate(archive):
                if member.isdir():
                    continue
                if not member.isfile():
                    raise SystemExit(f"Non-regular archive member requires review: {filename}:{member.name}")
                content = archive.extractfile(member).read()
                name = Path(member.name).name
                bubble = filename.startswith("gentoo-bubble-icons-")
                removed = name in KNOWN_REMOVED
                evidence = ""
                if bubble:
                    evidence = f"{url}#gentoo-bubble-icons/README"
                    status = "EXPLICIT_COLLECTION_NOTICE_UNDERLYING_RIGHTS_UNRESOLVED"
                    license_notice = "CC-BY-2.0"
                else:
                    status = "NO_EXPLICIT_LICENSE_GRANT_LOCATED"
                    license_notice = ""
                if removed:
                    status = "HISTORICAL_REDISTRIBUTION_CONCERN_REMOVED_BEFORE_INSTALL"
                    evidence = "https://bugs.gentoo.org/132271"
                inspected = metadata(content, member.name)
                row = {
                    "archive": filename, "member_index": index, "member": member.name,
                    "size": member.size, "sha256": digest(content),
                    "archive_url": url, "license_notice": license_notice,
                    "status": status, "evidence": evidence,
                    "credit_filename_hint": "; ".join(sorted(credits.get(name, []))),
                    "review_hint": "filename suggests third-party/base artwork; visual/provenance review needed"
                                   if REVIEW_NAMES.search(name) else "provenance review needed",
                    "dimensions": inspected["dimensions"],
                    "license_metadata_hits": json.dumps(inspected["license_hits"], ensure_ascii=True),
                    "metadata_error": inspected["error"],
                }
                archive_rows.append(row)
                metadata_results.append({"archive": filename, "member": member.name, **inspected})
        rows.extend(archive_rows)
        archive_results.append({"archive": filename, "url": url, "size": len(data),
                                "sha256": digest(data), "manifest_match": matched,
                                "regular_files": len(archive_rows)})

    by_hash = collections.defaultdict(list)
    for row in rows:
        by_hash[row["sha256"]].append(row)
    installed = []
    # Portage compresses documentation. Compare its decompressed bytes to origins.
    for path in sorted(args.image.rglob("*")):
        if not path.is_file():
            continue
        raw = path.read_bytes()
        content = raw
        if "usr/share/doc/" in str(path.relative_to(args.image)):
            for suffix, decompress in ((".gz", gzip.decompress), (".bz2", bz2.decompress), (".xz", lzma.decompress)):
                if path.name.endswith(suffix):
                    content = decompress(raw)
                    break
        matches = by_hash[digest(content)]
        installed.append({
            "installed_path": str(path.relative_to(args.image)),
            "sha256": digest(raw), "content_sha256": digest(content),
            "archive_origins": " | ".join(f"{r['archive']}:{r['member']}" for r in matches),
            "license_notices": "; ".join(sorted({r["license_notice"] for r in matches if r["license_notice"]})),
            "status": "ARCHIVE_CONTENT_MATCH_NOT_LEGAL_CLEARANCE" if matches else "PACKAGING_FILE_OR_TRANSFORM_REQUIRES_REVIEW",
        })
    if not installed:
        raise SystemExit("No staged files found; check --image and its permissions")
    fields = list(rows[0])
    write_csv(args.output_dir / "gentoo-artwork-archive-inventory.csv", rows, fields)
    write_csv(args.output_dir / "gentoo-artwork-installed-inventory.csv", installed, list(installed[0]))
    summary = {
        "archives": archive_results, "archive_file_records": len(rows),
        "archive_status_counts": dict(collections.Counter(r["status"] for r in rows)),
        "installed_files": len(installed),
        "installed_without_archive_hash_match": [r["installed_path"] for r in installed if not r["archive_origins"]],
        "metadata_license_hits": [r for r in metadata_results if r["license_hits"]],
        "metadata_errors": [{"archive": r["archive"], "member": r["member"], "error": r["error"]}
                            for r in metadata_results if r["error"]],
        "limitations": [
            "No license is inferred from an ebuild, filename, image format, or metadata absence.",
            "README grants do not independently prove rights to incorporated third-party artwork.",
            "Filename hints from CREDITS are not authenticated author identifications.",
            "Hash matches identify identical bytes, not which duplicate archive supplied the final file.",
            "Inventory and metadata inspection do not replace visual review or copyright-holder permission.",
        ],
    }
    (args.output_dir / "gentoo-artwork-audit-evidence.json").write_text(json.dumps(summary, indent=2) + "\n")
    print(json.dumps({k: v for k, v in summary.items()
                      if k in ("archive_file_records", "archive_status_counts", "installed_files",
                               "installed_without_archive_hash_match", "metadata_errors")}, indent=2))


if __name__ == "__main__":
    main()
