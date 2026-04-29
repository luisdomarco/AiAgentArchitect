#!/usr/bin/env python3
"""
AiAgentArchitect — Configuration resolver

Reads `config/config.base.toml`, `config/config.team.toml`, `config/config.user.toml`
in that precedence order, applies merge rules, and writes the result to
`config/.resolved.toml`.

Merge rules:
  - Scalars (str, int, float, bool): later overrides earlier.
  - Tables (dicts): deep merge; sub-keys merged recursively.
  - Arrays of scalars: replaced wholesale by later (no append).
  - Arrays of tables (each with `id`): merged by `id`; matching ids deep-merged,
    new ids appended.

Lock semantics:
  - A field `foo_lock = true` at team level prevents user/CLI overrides of `foo`.
  - Lock applies within the same table scope.

CLI flags:
  - `--cli-overrides <toml-string>`: ad-hoc top-priority overrides.
  - `--root <path>`: project root (defaults to script's parent's parent).
  - `--quiet`: suppress non-error output.

Exit codes:
  0  = success
  1  = malformed input file
  2  = lock violation (and `--strict` is passed)
"""

from __future__ import annotations

import argparse
import os
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

try:
    import tomllib  # Python 3.11+
except ModuleNotFoundError:
    try:
        import tomli as tomllib  # Python 3.7+ via `pip install tomli`
    except ModuleNotFoundError:
        sys.stderr.write(
            "ERROR: requires Python 3.11+ (tomllib) or `pip install tomli`.\n"
        )
        sys.exit(1)


def read_toml(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {}
    with path.open("rb") as f:
        return tomllib.load(f)


def is_lock_key(key: str) -> bool:
    return key.endswith("_lock")


def base_key_of_lock(lock_key: str) -> str:
    return lock_key[: -len("_lock")]


def collect_locks(table: dict[str, Any]) -> dict[str, bool]:
    """Return {field_name: True} for every `<field>_lock = true` in this table scope."""
    return {
        base_key_of_lock(k): bool(v)
        for k, v in table.items()
        if is_lock_key(k) and v is True
    }


def deep_merge(
    base: dict[str, Any],
    overlay: dict[str, Any],
    locked_fields: dict[str, bool] | None = None,
    path: str = "",
    warnings: list[str] | None = None,
) -> dict[str, Any]:
    """Merge `overlay` into `base`. `locked_fields` are fields that overlay cannot override."""
    if locked_fields is None:
        locked_fields = {}
    if warnings is None:
        warnings = []

    result = dict(base)
    for key, value in overlay.items():
        if is_lock_key(key):
            # Lock declarations are kept as-is (so resolver output records them).
            result[key] = value
            continue

        full_path = f"{path}.{key}" if path else key

        if key in locked_fields:
            warnings.append(
                f"Lock violation ignored: {full_path} is locked at a higher precedence layer."
            )
            continue

        if (
            isinstance(value, dict)
            and isinstance(result.get(key), dict)
        ):
            sub_locks = collect_locks(result[key])
            result[key] = deep_merge(
                result[key], value, sub_locks, full_path, warnings
            )
        elif (
            isinstance(value, list)
            and value
            and isinstance(value[0], dict)
            and "id" in value[0]
        ):
            result[key] = merge_array_of_tables(
                result.get(key, []), value, full_path, warnings
            )
        else:
            result[key] = value
    return result


def merge_array_of_tables(
    base: list[dict[str, Any]],
    overlay: list[dict[str, Any]],
    path: str,
    warnings: list[str],
) -> list[dict[str, Any]]:
    """Arrays of tables keyed by `id`: matching ids deep-merged, new ones appended."""
    by_id = {item.get("id"): dict(item) for item in base if isinstance(item, dict)}
    for item in overlay:
        if not isinstance(item, dict) or "id" not in item:
            continue
        item_id = item["id"]
        if item_id in by_id:
            sub_path = f"{path}[id={item_id}]"
            sub_locks = collect_locks(by_id[item_id])
            by_id[item_id] = deep_merge(
                by_id[item_id], item, sub_locks, sub_path, warnings
            )
        else:
            by_id[item_id] = dict(item)
    return list(by_id.values())


def dump_toml(table: dict[str, Any], prefix: str = "") -> str:
    """Minimal TOML writer covering the subset we use: tables, scalars, simple arrays.

    `prefix` is the dotted path to the current table (e.g. "_meta") so that
    nested tables are emitted with their full path: `[_meta.sources]`.
    """
    lines: list[str] = []
    scalars: dict[str, Any] = {}
    sub_tables: dict[str, dict[str, Any]] = {}
    for key, value in table.items():
        if isinstance(value, dict):
            sub_tables[key] = value
        else:
            scalars[key] = value
    for key, value in scalars.items():
        lines.append(f"{key} = {render_value(value)}")
    for key, sub in sub_tables.items():
        lines.append("")
        full = f"{prefix}.{key}" if prefix else key
        lines.append(f"[{full}]")
        lines.append(dump_toml(sub, full).rstrip())
    return "\n".join(lines) + "\n"


def render_value(v: Any) -> str:
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)):
        return str(v)
    if isinstance(v, str):
        escaped = v.replace("\\", "\\\\").replace('"', '\\"')
        return f'"{escaped}"'
    if isinstance(v, list):
        return "[" + ", ".join(render_value(x) for x in v) + "]"
    raise TypeError(f"Unsupported TOML value type: {type(v).__name__}")


def parse_cli_overrides(toml_str: str | None) -> dict[str, Any]:
    if not toml_str:
        return {}
    return tomllib.loads(toml_str)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--root",
        type=Path,
        default=Path(__file__).resolve().parent.parent,
        help="Project root containing config/",
    )
    parser.add_argument(
        "--cli-overrides",
        type=str,
        default=None,
        help="Inline TOML string to apply as top-priority overrides",
    )
    parser.add_argument("--quiet", action="store_true")
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Exit non-zero if any lock violation occurs",
    )
    args = parser.parse_args()

    config_dir = args.root / "config"
    if not config_dir.exists():
        sys.stderr.write(f"ERROR: {config_dir} not found.\n")
        return 1

    base = read_toml(config_dir / "config.base.toml")
    team = read_toml(config_dir / "config.team.toml")
    user = read_toml(config_dir / "config.user.toml")
    cli = parse_cli_overrides(args.cli_overrides)

    warnings: list[str] = []

    # base (no locks possible at base level by definition; team owns locks)
    merged = deep_merge(base, team, collect_locks(base), "", warnings)
    # apply user, respecting team-declared locks
    team_locks = {}
    for table_name, table in team.items():
        if isinstance(table, dict):
            team_locks[table_name] = collect_locks(table)
    merged_with_user = dict(merged)
    for table_name, sub in user.items():
        if isinstance(sub, dict) and isinstance(merged_with_user.get(table_name), dict):
            merged_with_user[table_name] = deep_merge(
                merged_with_user[table_name],
                sub,
                team_locks.get(table_name, {}),
                table_name,
                warnings,
            )
        elif table_name in (team_locks.get("__top__", {})):
            warnings.append(f"Lock violation ignored: {table_name} locked at team.")
        else:
            merged_with_user[table_name] = sub

    # apply CLI overrides (highest precedence; only blocked by team locks marked _lock)
    final = dict(merged_with_user)
    for table_name, sub in cli.items():
        if isinstance(sub, dict) and isinstance(final.get(table_name), dict):
            final[table_name] = deep_merge(
                final[table_name],
                sub,
                team_locks.get(table_name, {}),
                f"cli.{table_name}",
                warnings,
            )
        else:
            final[table_name] = sub

    # Add resolution metadata
    final["_meta"] = {
        "resolved_at": datetime.now(timezone.utc).isoformat(),
        "sources": {
            "base": str((config_dir / "config.base.toml").relative_to(args.root)),
            "team": str((config_dir / "config.team.toml").relative_to(args.root))
            if (config_dir / "config.team.toml").exists()
            else "",
            "user": str((config_dir / "config.user.toml").relative_to(args.root))
            if (config_dir / "config.user.toml").exists()
            else "",
            "cli_overrides_applied": bool(cli),
        },
    }

    output = config_dir / ".resolved.toml"
    header = (
        "# AUTO-GENERATED by scripts/resolve-config.py — DO NOT EDIT BY HAND.\n"
        "# Edit config.base.toml, config.team.toml, or config.user.toml instead.\n\n"
    )
    output.write_text(header + dump_toml(final), encoding="utf-8")

    if not args.quiet:
        sys.stdout.write(f"Resolved config written to {output.relative_to(args.root)}\n")
        for w in warnings:
            sys.stderr.write(f"WARNING: {w}\n")

    if args.strict and warnings:
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
