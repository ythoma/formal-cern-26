# FSM transition coverage example

This example implements the four-state Moore machine shown in the coverage lesson. The machine and its PSL coverage directives are in `src_vhdl/coverage_fsm.vhd`; the cover statements are embedded in the architecture and sample the internal `state` signal on rising edges of `clk`. There is no separate PSL vunit or `state_o` observation port in the current version.

## State transitions

| Current state | `d` | Next state | `y` |
| --- | --- | --- | --- |
| `s1` | `1` | `s1` | `0` |
| `s1` | `0` | `s2` | `0` |
| `s2` | `0` | `s2` | `0` |
| `s2` | `1` | `s3` | `0` |
| `s3` | `0` | `s2` | `0` |
| `s3` | `1` | `s4` | `0` |
| `s4` | either | `s1` | `1` while in `s4` |

The initial state is `s1`. State changes on each rising edge of `clk`; `y` is a Moore output and is high only while the current state is `s4`. The input `d` has no assumptions in this example. The embedded PSL defines one cover goal for each of the seven transitions.

## Run the coverage task

From this directory, run:

```sh
cd scripts
sby --yosys "yosys -m ghdl" -f run.sby cover
```

This selects the `cover` task, which uses a depth of 10 and the `smtbmc z3` engine. With the initialized state and unconstrained input, all seven transition goals should be reachable. SBY reports reached goals in the task log and writes witness traces under the task/engine output directory; use the paths reported by SBY. A reached transition demonstrates reachability, not correctness of a separate assertion.

## Files

- `src_vhdl/coverage_fsm.vhd` — FSM RTL and embedded PSL transition covers.
- `scripts/run.sby` — SBY cover task configuration.
