#!/usr/bin/env python3
"""Alias declared distfile records in pnpm 11's temporary SQLite store."""
import sqlite3
import sys
from pathlib import Path

store = Path(sys.argv[1])
with sqlite3.connect(store / "v11/index.db") as database:
    records = database.execute("SELECT key, data FROM package_index").fetchall()
    for line in sys.stdin:
        filename, package_id, uri = line.rstrip("\n").split("\t")
        matches = [(key, data) for key, data in records
                   if key.split("\t", 1)[-1].endswith("/" + filename)]
        if len(matches) != 1:
            raise RuntimeError(f"expected one store record for {filename}: {len(matches)}")
        key, data = matches[0]
        integrity = key.split("\t", 1)[0]
        aliases = [integrity + "\t" + package_id]
        if "@https://" in package_id:
            aliases.extend(identifier + "\t" + state
                           for identifier in (package_id, uri)
                           for state in ("built", "not-built"))
        for alias in aliases:
            database.execute("INSERT OR REPLACE INTO package_index (key, data) VALUES (?, ?)",
                             (alias, data))
print("Aliased pnpm 11 store records from declared distfiles")
