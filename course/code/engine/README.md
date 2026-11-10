# Checking installed SBY engines and solvers

Use this folder to inspect which SBY mode/engine/solver combinations work in the active OSS CAD Suite environment. SBY's supported mode/engine table is not the same as the set of executables installed on a machine.

From this directory, initialize the course tool environment and list the installed SBY executables:

```sh
startsby
sby --version
for tool in yosys yosys-abc yosys-smtbmc btormc pono rIC3 suprove avy aigbmc z3 yices boolector bitwuzla cvc4 cvc5; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf '%-14s %s\n' "$tool" "$(command -v "$tool")"
  fi
done
```

Run the enumerator from this directory after `startsby`:

```sh
/bin/python check_engines.py
```

The script checks every SBY v0.69 mode/engine/solver combination in the matrix below for which its external executable is found. It builds a temporary probe project per combination and reports `PASS`, `FAIL`, `TIMEOUT`, `SKIP`, or `UNVALIDATED`; it does not modify the source tree. The `live` test uses a tautological liveness property solely to test mode/engine integration, not design progress. GHDL/Yosys may fail to emit a live property in a form SBY can report; that is `UNVALIDATED`, not a confirmed engine failure. Tool presence and a smoke-test PASS do not guarantee that the engine can handle a course design or that a nontrivial proof will converge.

## SBY v0.69 reference matrix

The course OSS CAD Suite snapshot currently contains SBY v0.69. Its supported combinations, as listed in the SBY reference and engine adapters, are:

| Mode | Engine / solver combinations |
| --- | --- |
| `bmc` | `smtbmc` with supported solver; `btor btormc`, `btor pono`, `btor rIC3`; `abc bmc3`, `abc sim3`; `aiger aigbmc`, `aiger rIC3` |
| `prove` | `smtbmc` with supported solver; `abc pdr`; `aiger avy`, `aiger suprove`, `aiger rIC3`; `btor rIC3` |
| `cover` | `smtbmc` with supported solver; `btor btormc` |
| `live` | `aiger suprove` |

This matrix records SBY-level support, not guaranteed availability of each external solver. Solver and engine support may change with the installed SBY/Yosys bundle; confirm locally before teaching or relying on a configuration. A BMC PASS remains bounded, and a prove-mode PASS is scoped to the encoded model, assumptions, and property.

## Example configuration

`engine_probe.vhd` is a small toggle-register design with a safety assertion and cover goal; `engine_probe_live.vhd` is a separate liveness-mode smoke design. `probe.sby` remains a manual template for the baseline combinations (`abc bmc3`, `abc pdr`, and `smtbmc z3`).

## Reference

The course engine/mode slide is [OSFV_09_Engines.tex](../../OSFV_09_Engines.tex#L217-L228). The official [SBY reference](https://symbiyosys.readthedocs.io/en/latest/reference.html) documents supported modes and engine combinations.
