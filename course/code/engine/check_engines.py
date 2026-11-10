#!/usr/bin/env python3
"""Probe locally installed SymbiYosys engine/solver combinations.

Run from this directory after sourcing the OSS CAD Suite environment (the
course helper is ``startsby``). Each candidate gets a fresh temporary SBY
project and a tiny VHDL design with meaningful assert/cover properties.
"""

from __future__ import annotations

import shutil
import subprocess
import tempfile
import argparse
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parent
PROBE = ROOT / "engine_probe.vhd"
LIVE_PROBE = ROOT / "engine_probe_live.vhd"
YOSYS_COMMAND = 'yosys -m ghdl'

# Engine adapters supported by the course's SBY v0.69. External executables
# are checked separately so the report distinguishes absent tools from errors.
SMT_SOLVERS = (
    ("yices", "yices"),
    ("boolector", "boolector"),
    ("bitwuzla", "bitwuzla"),
    ("z3", "z3"),
    ("mathsat", "mathsat"),
    ("cvc4", "cvc4"),
    ("cvc5", "cvc5"),
)


@dataclass(frozen=True)
class Candidate:
    mode: str
    engine: str
    executable: str

    @property
    def label(self) -> str:
        return f"{self.mode:5} {self.engine}"


def candidates() -> list[Candidate]:
    result: list[Candidate] = []
    for solver, executable in SMT_SOLVERS:
        for mode in ("bmc", "prove", "cover"):
            result.append(Candidate(mode, f"smtbmc {solver}", executable))

    result.extend(
        [
            Candidate("bmc", "abc bmc3", "yosys-abc"),
            Candidate("bmc", "abc sim3", "yosys-abc"),
            Candidate("prove", "abc pdr", "yosys-abc"),
            Candidate("bmc", "btor btormc", "btormc"),
            Candidate("cover", "btor btormc", "btormc"),
            Candidate("bmc", "btor pono", "pono"),
            Candidate("bmc", "btor rIC3", "rIC3"),
            Candidate("prove", "btor rIC3", "rIC3"),
            Candidate("bmc", "aiger aigbmc", "aigbmc"),
            Candidate("bmc", "aiger rIC3", "rIC3"),
            Candidate("prove", "aiger rIC3", "rIC3"),
            Candidate("prove", "aiger avy", "avy"),
            Candidate("prove", "aiger suprove", "suprove"),
            Candidate("live", "aiger suprove", "suprove"),
        ]
    )
    return result


def make_sby(candidate: Candidate, project: Path, source: str) -> Path:
    (project / "engine_probe.vhd").write_text(source, encoding="utf-8")
    options = [f"mode {candidate.mode}"]
    if candidate.mode in ("bmc", "cover"):
        options.append("depth 8")

    config = "\n".join(
        [
            "[options]",
            *options,
            "",
            "[engines]",
            candidate.engine,
            "",
            "[script]",
            "ghdl --std=08 -fpsl engine_probe.vhd -e engine_probe",
            "prep -top engine_probe",
            "",
            "[files]",
            "engine_probe.vhd",
            "",
        ]
    )
    path = project / "probe.sby"
    path.write_text(config, encoding="utf-8")
    return path


def run_candidate(candidate: Candidate, source: str) -> tuple[str, str]:
    if shutil.which(candidate.executable) is None:
        return "SKIP", f"missing executable: {candidate.executable}"

    project = Path(tempfile.mkdtemp(prefix="sby-engine-probe-"))
    config = make_sby(candidate, project, source)
    try:
        run = subprocess.run(
            ["sby", "--yosys", YOSYS_COMMAND, "-f", config.name],
            cwd=project,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            timeout=20,
            check=False,
        )
    except subprocess.TimeoutExpired:
        return "TIMEOUT", f"exceeded 20 seconds; artifacts: {project}"

    output = run.stdout
    if run.returncode == 0 and "DONE (PASS" in output:
        shutil.rmtree(project, ignore_errors=True)
        return "PASS", "probe completed"

    # Keep failing outputs so users can inspect SBY's task log and engine log.
    useful = [line.strip() for line in output.splitlines() if "ERROR" in line.upper()]
    detail = " | ".join(useful[-3:]) if useful else f"sby exit status {run.returncode}"
    if candidate.mode == "live" and "Could not determine engine status" in output:
        return "UNVALIDATED", f"GHDL probe emitted no SBY live status ({detail}); artifacts: {project}"
    return "FAIL", f"{detail}; artifacts: {project}"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--mode", choices=("bmc", "prove", "cover", "live"), help="probe only one SBY mode")
    parser.add_argument("--engine", help="probe only candidates whose engine/solver contains this text")
    args = parser.parse_args()

    if shutil.which("sby") is None or shutil.which("yosys") is None or shutil.which("ghdl") is None:
        print("ERROR: run this script after startsby; sby, yosys, and ghdl must be on PATH.")
        return 2

    live_source = LIVE_PROBE.read_text(encoding="utf-8")
    base_source = PROBE.read_text(encoding="utf-8")
    print(f"SBY: {subprocess.run(['sby', '--version'], text=True, capture_output=True).stdout.strip()}")
    print(f"Probe directory: {ROOT}")
    print("\nMode / engine / solver availability and probe result:")

    counts = {"PASS": 0, "SKIP": 0, "UNVALIDATED": 0, "FAIL": 0, "TIMEOUT": 0}
    selected = [candidate for candidate in candidates()
                if (args.mode is None or candidate.mode == args.mode)
                and (args.engine is None or args.engine in candidate.engine)]
    for candidate in selected:
        source = live_source if candidate.mode == "live" else base_source
        status, detail = run_candidate(candidate, source)
        counts[status] += 1
        print(f"{status:7} {candidate.label:28} {detail}")

    print("\nSummary: " + ", ".join(f"{key}={value}" for key, value in counts.items()))
    print("A PASS validates only this small smoke design and selected configuration; it is not a benchmark or a guarantee of convergence on course designs.")
    return 1 if counts["FAIL"] or counts["TIMEOUT"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
