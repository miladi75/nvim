#!/usr/bin/env python3
"""Generate .tutor.json expect files for the nvim tutorial chapters.

Neovim's :Tutor checks exercise lines against `expect` entries keyed by
line number. Authoring line numbers by hand breaks on every edit, so this
script locates each exercise line by its exact text and emits the json.

Specs are (current_text, expected_text) pairs in file order. Duplicate
current_text lines are consumed in order; expected_text None consumes an
occurrence without emitting a check (used to skip e.g. the first of four
identical lines). Run after any chapter edit:

    python3 build_expects.py
"""

import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent

SPECS = {
    "tutorial-01-basics.tutor": [
        ("2 + 2 =",
         "2 + 2 = 4"),
        ("important: always read the manual",
         "NB! important: always read the manual"),
        ("fix this typpo by deleting one letter",
         "fix this typo by deleting one letter"),
        ("remove extra extra word here",
         "remove extra word here"),
        ("this sentence ends here. ends here.",
         "this sentence ends here."),
        ("this lime needs fixing",
         "this line needs fixing"),
        ("replace this entire line with something better",
         "fresh start"),
        ("press r9 on the zero: 0",
         "press r9 on the zero: 9"),
        ("mistakes mistakes everywhere",
         "lessons lessons everywhere"),
    ],
    "tutorial-02-motions.tutor": [
        ("The compiler found found an error in the design.",
         "The compiler found an error in the design."),
        ("update(sensor_id, calibration_data)",
         "update(sensor_id)"),
        ("signal counter : integer range 0 to 255]",
         "signal counter : integer range 0 to 255;"),
        ("path=/usr/share/nvim/runtime backup_path=/tmp/old_config",
         "backup_path=/tmp/old_config"),
        ("one two three four five six",
         "four five six"),
        ("if (mask and (flags or enable)) else fallback",
         "if (mask and ) else fallback"),
    ],
    "tutorial-03-operators.tutor": [
        ('print("helo wrold")',
         'print("hello world")'),
        ("result = compute(temp_value, debug_mode) + offset",
         "result = compute + offset"),
        ("<title>Old Page Title</title>",
         "<title>Neovim Power User</title>"),
        ("config = { retries = 3, timeout = 30 }",
         "config = {}"),
        ("keep calm and edit text",
         "KEEP CALM AND EDIT TEXT"),
        ("local widths = {",
         "local widths = { 8, 16, 32 }"),
    ],
    "tutorial-04-registers.tutor": [
        ("local target = SCRATCH",
         "local target = GOLDEN_VALUE"),
        ("total_bytes =",
         "total_bytes = 1024"),
    ],
    "tutorial-05-search.tutor": [
        ("count = foo_bar + 1",
         "count = baz_qux + 1"),
        ("print(foo_bar)",
         "print(baz_qux)"),
        ("return foo_bar + offset",
         "return baz_qux + offset"),
        ("the quick fox and the lazy dog and the cat",
         "THE quick fox and THE lazy dog and THE cat"),
        ("Doe, Jane",
         "Jane Doe"),
        ("version-1.2.3",
         "version-9.2.3"),
        ("data_out <= shift_reg(7); -- DEBUG",
         "data_out <= shift_reg(7);"),
        ("irq_flag <= '1'; -- DEBUG",
         "irq_flag <= '1';"),
    ],
    "tutorial-06-macros.tutor": [
        ("buy milk", "- [ ] Buy milk"),
        ("clean desk", "- [ ] Clean desk"),
        ("fix flaky test", "- [ ] Fix flaky test"),
        ("err_timeout", "ERR_TIMEOUT"),
        ("err_overflow", "ERR_OVERFLOW"),
        ("err_crc_mismatch", "ERR_CRC_MISMATCH"),
    ],
    "tutorial-07-navigation.tutor": [
        ("waypoint alpha -- mark me with ma",
         "waypoint alpha -- mark me with ma (visited)"),
        ("notes:",
         "notes: draft v2"),
    ],
    "tutorial-08-visualblock.tutor": [
        ("x_out <= a_in and b_in;", "-- x_out <= a_in and b_in;"),
        ("y_out <= a_in or b_in;", "-- y_out <= a_in or b_in;"),
        ("z_out <= a_in xor b_in;", "-- z_out <= a_in xor b_in;"),
        ("latency 12ms", "latency 12ms [ok]"),
        ("throughput 9000pps", "throughput 9000pps [ok]"),
        ("jitter 3ms", "jitter 3ms [ok]"),
        ("retry_count = 7", "retry_count = 12"),
        ("channel_0", None),  # first copy stays untouched
        ("channel_0", "channel_1"),
        ("channel_0", "channel_2"),
        ("channel_0", "channel_3"),
    ],
}


def build(name: str, specs) -> bool:
    path = HERE / name
    lines = path.read_text().splitlines()
    expect = {}
    cursor = 0
    ok = True
    for current, expected in specs:
        try:
            idx = lines.index(current, cursor)
        except ValueError:
            print(f"{name}: NOT FOUND after line {cursor}: {current!r}")
            ok = False
            continue
        cursor = idx + 1
        if expected is None:
            continue
        if expected == current:
            print(f"{name}: expected == current at line {idx + 1}: {current!r}")
            ok = False
            continue
        expect[str(idx + 1)] = expected
    out = path.with_name(path.name + ".json")
    out.write_text(json.dumps({"expect": expect}, indent=2) + "\n")
    print(f"{name}: {len(expect)} checks -> {out.name}")
    return ok


def main() -> int:
    all_ok = all([build(name, specs) for name, specs in sorted(SPECS.items())])
    return 0 if all_ok else 1


if __name__ == "__main__":
    sys.exit(main())
