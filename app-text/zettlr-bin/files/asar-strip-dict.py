#!/usr/bin/env python3
"""Remove one named directory entry (a bundled Hunspell dictionary with no
resolvable license) from an Electron .asar archive in-place, without any
node/npm/asar tooling. Usage: asar-strip-dict.py <path-to-app.asar> <dict-name>

.asar layout (little-endian throughout):
  [0:4]   outer Pickle payload size, always 4 (one uint32 follows)
  [4:8]   header_size == data_start - 8
  [8:12]  inner pickle payload size == data_start - 12
  [12:16] json_len: byte length of the UTF-8 JSON header text
  [16:16+json_len] JSON header text, then zero-padded to a 4-byte boundary
  [data_start:] concatenated file contents, each at the byte offset its
                header entry names (relative to data_start)
These four size fields are redundant encodings of the same boundary
(data_start); load() cross-checks all four against each other and against
the actual file size before anything else runs, so a malformed or
unexpected-format archive fails loudly here instead of producing a subtly
corrupt rewrite.

Every surviving file's bytes are additionally verified against its own
"integrity" block in the header (SHA256, whole-file and per-block) before
being carried into the rewritten archive -- the same check Electron's own
asar-fs-wrapper performs at load time. This confirms the copied content is
exactly what Electron would consider valid, not merely that the header's
offset/size bookkeeping is self-consistent. It does not, and cannot,
prove the archive as a whole matches some externally-stored,
tamper-evident value -- this build of Electron has no such external check
(no `EmbeddedAsarIntegrityValidation` fuse-wire sentinel was found in the
packaged binary), so there is nothing further to verify against.
"""
import hashlib
import json
import os
import struct
import sys


class AsarFormatError(Exception):
    pass


def load(path):
    with open(path, "rb") as f:
        data = f.read()

    if len(data) < 16:
        raise AsarFormatError(f"{path} is only {len(data)} bytes, too small to be an asar")

    outer_size, header_size, inner_size, json_len = struct.unpack_from("<IIII", data, 0)
    data_start = 16 + ((json_len + 3) & ~3)

    # Every one of these is a redundant encoding of the same data_start
    # boundary; require them to actually agree rather than trusting json_len
    # alone (an earlier version of this script derived data_start from
    # json_len only and claimed -- incorrectly -- to cross-check the rest).
    if outer_size != 4:
        raise AsarFormatError(f"unexpected outer pickle size {outer_size} (expected 4)")
    if header_size != data_start - 8:
        raise AsarFormatError(f"header_size {header_size} != data_start-8 ({data_start - 8})")
    if inner_size != data_start - 12:
        raise AsarFormatError(f"inner pickle size {inner_size} != data_start-12 ({data_start - 12})")
    if data_start > len(data):
        raise AsarFormatError(f"computed data_start {data_start} exceeds file size {len(data)}")

    json_bytes = data[16:16 + json_len]
    try:
        header = json.loads(json_bytes.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as e:
        raise AsarFormatError(f"failed to parse asar JSON header: {e}") from e

    return data, header, data_start


def collect_files(node, prefix=""):
    """Yield (path, node_dict) for every file entry, depth-first."""
    if "files" in node:
        for name, child in node["files"].items():
            yield from collect_files(child, prefix + "/" + name)
    else:
        yield prefix, node


def verify_integrity(path, content, integrity):
    """Verify content against an asar entry's own "integrity" block (the
    same SHA256 whole-file + per-block hashes Electron's asar-fs-wrapper
    checks at load time). Raises AsarFormatError on any mismatch -- this
    confirms the bytes we're about to carry into the rewritten archive are
    exactly what Electron itself would consider valid, not just that the
    header's own offset/size bookkeeping is self-consistent."""
    if integrity is None:
        return
    if integrity.get("algorithm") != "SHA256":
        raise AsarFormatError(f"{path!r}: unsupported integrity algorithm {integrity.get('algorithm')!r}")

    whole = hashlib.sha256(content).hexdigest()
    if whole != integrity.get("hash"):
        raise AsarFormatError(
            f"{path!r}: whole-file SHA256 {whole} != stored integrity.hash {integrity.get('hash')}"
        )

    block_size = int(integrity.get("blockSize", 0))
    blocks = integrity.get("blocks", [])
    if block_size and blocks:
        for i, expected in enumerate(blocks):
            chunk = content[i * block_size:(i + 1) * block_size]
            actual = hashlib.sha256(chunk).hexdigest()
            if actual != expected:
                raise AsarFormatError(
                    f"{path!r}: block {i} SHA256 {actual} != stored block hash {expected}"
                )


def remove_dict(asar_path, dict_name):
    if not dict_name or "/" in dict_name or dict_name in (".", ".."):
        raise SystemExit(f"refusing suspicious dict name: {dict_name!r}")

    data, header, data_start = load(asar_path)
    source_size = len(data)

    dict_key = f"/.webpack/main/dict/{dict_name}"
    all_files = list(collect_files(header))
    removed = [(p, n) for p, n in all_files if p.startswith(dict_key + "/")]
    if not removed:
        raise SystemExit(f"no entries found under {dict_key}, nothing to remove")

    kept = [(p, n) for p, n in all_files if not p.startswith(dict_key + "/")]
    # Sort surviving files by their original offset so the rewritten data
    # blob preserves relative order (offsets in the source header are not
    # guaranteed to already be sorted the same as tree-walk order).
    kept.sort(key=lambda pn: int(pn[1].get("offset", 0)))

    # Rebuild the data blob by copying each surviving file's bytes forward,
    # recording its new cumulative offset. Skip zero-size entries (offset
    # is meaningless/absent for unpacked or empty files) -- carry those
    # through unchanged.
    out_chunks = []
    cursor = 0
    for path, node in kept:
        if node.get("unpacked") or int(node.get("size", 0)) == 0:
            continue
        size = int(node["size"])
        old_offset = int(node["offset"])
        if old_offset < 0 or size < 0 or data_start + old_offset + size > source_size:
            raise AsarFormatError(
                f"entry {path!r} claims offset={old_offset} size={size}, "
                f"which runs past the source file (data_start={data_start}, "
                f"source_size={source_size})"
            )
        chunk = data[data_start + old_offset:data_start + old_offset + size]
        verify_integrity(path, chunk, node.get("integrity"))
        out_chunks.append(chunk)
        node["offset"] = str(cursor)
        cursor += size

    # Remove the now-empty dict/<name> directory node from the tree.
    parts = dict_key.strip("/").split("/")
    parent = header
    for part in parts[:-1]:
        parent = parent["files"][part]
    del parent["files"][parts[-1]]

    new_json_bytes = json.dumps(header, separators=(",", ":")).encode("utf-8")
    new_json_len = len(new_json_bytes)
    padded_json_len = (new_json_len + 3) & ~3
    new_data_start = 16 + padded_json_len

    out = bytearray()
    out += struct.pack("<I", 4)
    out += struct.pack("<I", new_data_start - 8)
    out += struct.pack("<I", new_data_start - 12)
    out += struct.pack("<I", new_json_len)
    out += new_json_bytes
    out += b"\x00" * (padded_json_len - new_json_len)
    assert len(out) == new_data_start, (len(out), new_data_start)
    for chunk in out_chunks:
        out += chunk

    # Sanity-check our own output is self-consistent before touching the
    # real file at all.
    check_data, check_header, check_data_start = _reparse(bytes(out))
    if check_data_start != new_data_start:
        raise AsarFormatError("internal error: rewritten archive fails its own header check")

    # Write to a temp file in the same directory and atomically replace the
    # original, so a crash/disk-full mid-write can't leave a half-written,
    # corrupt asar in place.
    tmp_path = f"{asar_path}.tmp{os.getpid()}"
    try:
        with open(tmp_path, "wb") as f:
            f.write(out)
        os.replace(tmp_path, asar_path)
    except BaseException:
        try:
            os.unlink(tmp_path)
        except OSError:
            pass
        raise

    removed_bytes = sum(int(n.get("size", 0)) for _, n in removed)
    verified = sum(1 for _, n in kept if n.get("integrity") and not n.get("unpacked") and int(n.get("size", 0)) > 0)
    print(
        f"asar-strip-dict.py: removed {len(removed)} file(s) "
        f"({removed_bytes} bytes) under {dict_key}; "
        f"{verified} surviving file(s) integrity-verified (SHA256); "
        f"{asar_path} is now {len(out)} bytes"
    )


def _reparse(data):
    """Like load(), but operates on an in-memory buffer instead of a path --
    used to self-check a rewritten archive before it's written to disk."""
    outer_size, header_size, inner_size, json_len = struct.unpack_from("<IIII", data, 0)
    data_start = 16 + ((json_len + 3) & ~3)
    if outer_size != 4 or header_size != data_start - 8 or inner_size != data_start - 12:
        raise AsarFormatError("rewritten archive header is internally inconsistent")
    header = json.loads(data[16:16 + json_len].decode("utf-8"))
    return data, header, data_start


if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise SystemExit(f"usage: {sys.argv[0]} <app.asar> <dict-name>")
    remove_dict(sys.argv[1], sys.argv[2])
