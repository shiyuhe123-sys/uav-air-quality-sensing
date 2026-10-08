"""Extract an ArduPilot DataFlash BIN log into loss-aware CSV files.

The extractor deliberately writes one CSV per message type. Native sample
times and fields are retained, while LogTimeS provides a common time origin
for MATLAB analysis. Derived files are reproducible from the untouched BIN.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import math
import re
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from pymavlink import mavutil


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", required=True, type=Path, help="ArduPilot .bin log")
    parser.add_argument("--output", required=True, type=Path, help="Output directory")
    return parser.parse_args()


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def csv_value(value: Any) -> Any:
    if value is None:
        return ""
    if isinstance(value, bytes):
        return value.hex()
    if isinstance(value, (list, tuple, dict)):
        return json.dumps(value, separators=(",", ":"))
    if isinstance(value, float) and not math.isfinite(value):
        return str(value)
    return value


def safe_filename(message_name: str) -> str:
    return re.sub(r"[^A-Za-z0-9_.-]", "_", message_name)


def normalise_unit(unit: str) -> str:
    # Some pymavlink builds decode the microseconds symbol with a replacement
    # character. Keep the meaning explicit and portable in metadata.
    if unit in {"�s", "µs", "μs"}:
        return "us"
    return unit


def main() -> None:
    args = parse_args()
    source = args.input.resolve()
    output = args.output.resolve()
    if not source.is_file():
        raise FileNotFoundError(source)

    output.mkdir(parents=True, exist_ok=True)
    reader = mavutil.mavlink_connection(str(source))

    rows: dict[str, list[dict[str, Any]]] = defaultdict(list)
    field_order: dict[str, list[str]] = {}
    units: dict[str, dict[str, str]] = {}
    first_time_us: int | None = None
    first_time_ms: int | None = None

    while True:
        message = reader.recv_match(blocking=False)
        if message is None:
            break

        message_name = message.get_type()
        if message_name == "BAD_DATA":
            continue

        row = message.to_dict()
        row.pop("mavpackettype", None)
        rows[message_name].append(row)

        for field in row:
            if field not in field_order.setdefault(message_name, []):
                field_order[message_name].append(field)

        if "TimeUS" in row and row["TimeUS"] is not None:
            value = int(row["TimeUS"])
            first_time_us = value if first_time_us is None else min(first_time_us, value)
        if "TimeMS" in row and row["TimeMS"] is not None:
            value = int(row["TimeMS"])
            first_time_ms = value if first_time_ms is None else min(first_time_ms, value)

        fmt = getattr(message, "fmt", None)
        if fmt is not None:
            fmt_columns = list(getattr(fmt, "columns", []))
            fmt_units = list(getattr(fmt, "units", []))
            units[message_name] = {
                column: normalise_unit(str(unit))
                for column, unit in zip(fmt_columns, fmt_units)
            }

    if first_time_us is None and first_time_ms is None:
        raise RuntimeError("The log contained no TimeUS or TimeMS values.")

    manifest_messages: dict[str, Any] = {}
    for message_name in sorted(rows):
        columns = field_order[message_name]
        csv_columns = ["LogTimeS", *columns]
        csv_path = output / f"{safe_filename(message_name)}.csv"

        with csv_path.open("w", newline="", encoding="utf-8") as stream:
            writer = csv.DictWriter(stream, fieldnames=csv_columns, extrasaction="ignore")
            writer.writeheader()
            for row in rows[message_name]:
                if "TimeUS" in row and first_time_us is not None:
                    log_time_s: float | str = (int(row["TimeUS"]) - first_time_us) / 1e6
                elif "TimeMS" in row and first_time_ms is not None:
                    log_time_s = (int(row["TimeMS"]) - first_time_ms) / 1e3
                else:
                    log_time_s = ""
                output_row = {key: csv_value(value) for key, value in row.items()}
                output_row["LogTimeS"] = log_time_s
                writer.writerow(output_row)

        manifest_messages[message_name] = {
            "count": len(rows[message_name]),
            "csv": csv_path.name,
            "fields": columns,
            "units": units.get(message_name, {}),
        }

    firmware_messages = [
        str(row.get("Message", ""))
        for row in rows.get("MSG", [])
        if row.get("Message")
    ]
    stat = source.stat()
    manifest = {
        "schema_version": 1,
        "source": {
            "path": str(source),
            "size_bytes": stat.st_size,
            "modified_utc": datetime.fromtimestamp(stat.st_mtime, timezone.utc).isoformat(),
            "sha256": sha256_file(source),
        },
        "extraction": {
            "created_utc": datetime.now(timezone.utc).isoformat(),
            "parser": "pymavlink",
            "time_origin_us": first_time_us,
            "time_origin_ms": first_time_ms,
            "time_definition": "LogTimeS is relative to the earliest timestamp of the same base.",
        },
        "firmware_messages": firmware_messages,
        "messages": manifest_messages,
    }
    with (output / "manifest.json").open("w", encoding="utf-8") as stream:
        json.dump(manifest, stream, indent=2, ensure_ascii=False)

    print(f"Extracted {sum(len(value) for value in rows.values())} messages")
    print(f"Message types: {len(rows)}")
    print(f"Output: {output}")


if __name__ == "__main__":
    main()
