# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

"""Register Logseq's replacement ZVec package as unpacked files in its ASAR.

The two Pickles precede a payload whose file offsets are relative to its start:
https://github.com/electron/asar/blob/main/src/disk.ts
https://github.com/electron/asar/blob/main/src/pickle.ts
The updated SDK loader is appended to the payload. Other packed files retain
their bytes, offsets and hashes.
"""

import hashlib
import io
import json
from pathlib import Path
import shutil
import struct
import sys


def integrity(source):
    block_size = 4 * 1024 * 1024
    digest = hashlib.sha256()
    blocks = []
    while block := source.read(block_size):
        digest.update(block)
        blocks.append(hashlib.sha256(block).hexdigest())
    return {
        "algorithm": "SHA256",
        "hash": digest.hexdigest(),
        "blockSize": block_size,
        "blocks": blocks or [hashlib.sha256(b"").hexdigest()],
    }


def unpacked_entry(path):
    if path.is_symlink():
        raise ValueError(f"Unexpected binding symlink: {path}")
    if path.is_dir():
        return {
            "unpacked": True,
            "files": {p.name: unpacked_entry(p) for p in sorted(path.iterdir())},
        }
    with path.open("rb") as source:
        hashes = integrity(source)
    return {
        "size": path.stat().st_size,
        "unpacked": True,
        "integrity": hashes,
    }


def main(archive, package):
    replacement = json.loads((package / "package.json").read_text())
    if replacement["name"] != "@zvec/bindings-linux-arm64":
        raise ValueError("Not an arm64 ZVec binding package")
    if replacement["main"] != "zvec_node_binding.node":
        raise ValueError("Unexpected binding entry point")
    for name in (replacement["main"], "jieba_dict/jieba.dict.utf8", "jieba_dict/hmm_model.utf8"):
        if not (package / name).is_file():
            raise ValueError(f"Missing binding file: {name}")
    with (package / replacement["main"]).open("rb") as source:
        elf = source.read(20)
    if elf[:6] != b"\x7fELF\x02\x01" or struct.unpack("<H", elf[18:20])[0] != 183:
        raise ValueError("Binding is not a little-endian ELF64 AArch64 object")

    temporary = archive.with_name(archive.name + ".zvec")
    with archive.open("rb") as source:
        size_payload, header_size, header_payload, json_size = struct.unpack("<4I", source.read(16))
        if size_payload != 4 or header_payload != header_size - 4 or json_size > header_size - 8:
            raise ValueError("Invalid ASAR Pickle header")
        header = json.loads(source.read(json_size))
        zvec = header["files"]["node_modules"]["files"]["@zvec"]["files"]
        sdk_entry = zvec["zvec"]["files"]["package.json"]
        source.seek(8 + header_size + int(sdk_entry["offset"]))
        sdk = json.loads(source.read(sdk_entry["size"]))
        if sdk["version"] != replacement["version"] or sdk["optionalDependencies"].get(
            replacement["name"]
        ) != replacement["version"]:
            raise ValueError("Binding version does not match the bundled ZVec SDK")
        if not zvec["bindings-linux-x64"].get("unpacked"):
            raise ValueError("Unexpected packed x86-64 binding")
        if "bindings-linux-arm64" in zvec:
            raise ValueError("Archive already contains an arm64 binding")
        del zvec["bindings-linux-x64"]
        zvec["bindings-linux-arm64"] = unpacked_entry(package)

        # Electron resolves the addon through ASAR, but native Jieba opens its
        # dictionaries with ordinary filesystem I/O and needs their real paths.
        loader_entry = zvec["zvec"]["files"]["src"]["files"]["index.js"]
        source.seek(8 + header_size + int(loader_entry["offset"]))
        loader = source.read(loader_entry["size"]).decode("utf-8")
        old = "const bundledJiebaDictDir = path.join(bindingAssetDir, 'jieba_dict');"
        new = (
            "// Native Jieba cannot read Electron's virtual ASAR paths.\n"
            "const bundledJiebaDictDir = path.join(\n"
            r"  bindingAssetDir.replace(/([\\/]app\.asar)([\\/])/, '$1.unpacked$2'),"
            "\n  'jieba_dict');"
        )
        if loader.count(old) != 1:
            raise ValueError("Unexpected bundled ZVec dictionary loader")
        loader = loader.replace(old, new).encode("utf-8")
        payload_size = source.seek(0, 2) - 8 - header_size
        loader_entry.update(
            offset=str(payload_size), size=len(loader), integrity=integrity(io.BytesIO(loader))
        )

        encoded = json.dumps(header, separators=(",", ":"), ensure_ascii=False).encode("utf-8")
        padding = bytes(-len(encoded) % 4)
        payload_size = 4 + len(encoded) + len(padding)
        with temporary.open("wb") as target:
            target.write(struct.pack("<4I", 4, payload_size + 4, payload_size, len(encoded)))
            target.write(encoded)
            target.write(padding)
            source.seek(8 + header_size)
            shutil.copyfileobj(source, target)
            target.write(loader)
    temporary.chmod(archive.stat().st_mode & 0o777)
    temporary.replace(archive)
    print(f"Registered {replacement['name']} {replacement['version']} in {archive}")


if __name__ == "__main__":
    main(Path(sys.argv[1]), Path(sys.argv[2]))
