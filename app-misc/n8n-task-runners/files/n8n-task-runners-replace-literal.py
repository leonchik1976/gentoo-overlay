#!/usr/bin/env python3

import os
import sys
import tempfile
from pathlib import Path


def main() -> None:
	if len(sys.argv) != 4:
		raise SystemExit(f"usage: {sys.argv[0]} FILE ORIGINAL REPLACEMENT")

	path = Path(sys.argv[1])
	old, new = sys.argv[2:]
	data = path.read_text(encoding="utf-8")
	count = data.count(old)
	if count != 1:
		raise SystemExit(
			f"expected exactly one occurrence in {path}, found {count}"
		)

	updated = data.replace(old, new, 1)
	mode = path.stat().st_mode
	temporary = None
	try:
		with tempfile.NamedTemporaryFile(
			mode="w",
			encoding="utf-8",
			dir=path.parent,
			prefix=f".{path.name}.",
			delete=False,
		) as output:
			temporary = Path(output.name)
			output.write(updated)
			output.flush()
			os.fsync(output.fileno())
		os.chmod(temporary, mode)
		os.replace(temporary, path)
	except BaseException:
		if temporary is not None:
			temporary.unlink(missing_ok=True)
		raise


if __name__ == "__main__":
	main()
