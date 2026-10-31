# Modelling a 3D printer – Mini project

SC42155 Modelling of Dynamical Systems, 2026–2027.
Ermir Osmani, Federico Sacile.

MATLAB code for the mini project. The model is a CoreXY 3D printer with two DC motors and a heated nozzle. The code follows the three parts of the assignment:

1. physical modelling;
2. finite state machines;
3. hybrid systems.

## Requirements

- MATLAB.
- Control System Toolbox, needed only by `part-1/q1_4.m` (`ss`, `lsim`).
- Everything else uses only base MATLAB (`ode45`, plotting).

No other installation is needed.

## Repository structure

```
part-1/   Q1  Physical modelling
part-2/   Q2  Finite state machines
part-3/   Q3  Hybrid systems
```

### part-1: Physical modelling

| File | Content |
|---|---|
| `q1_4.m` | Decoupled x/y models of Q1.3 and the feed-forward inputs of Q1.4 for an ellipse and a star. It simulates both shapes with `lsim` and plots the paths and the motor voltages. |
| `q1_6.m` | Q1.6: cooling of the deposited filament (1D heat equation on a growing domain, finite volumes, explicit time step). It plots the temperature along the filament over time. |

### part-2: Finite state machines

| File | Content |
|---|---|
| `filament_fsm.m` | Moore machine of Q2.1 (filament replacement): inputs `C`, `F`, `done`, states q0 … q7 and their outputs. |
| `park_detector_step.m` | One transition of the head-parked detector of Q2.2 (4-state DFA). |
| `park_detector.m` | Runs the detector on a whole sequence of samples (M, m) and says whether the head is parked. |
| `main_part2.m` | Runs the examples of Q2.1 and Q2.2. |

### part-3: Hybrid systems

| File | Content |
|---|---|
| `main_part3.m` | **Main script.** Section Q3.1 (filament replacement) and section Q3.2 (draw a square). |
| `printer_model.m`, `params_printer.m` | Parameters: motors and head as in Q1, nozzle of Q1.5, thresholds and timings of Part 3. |
| `plant_flow.m` | Continuous dynamics: decoupled CoreXY axes (Q1.3), nozzle (Q1.5) and contact with the frame. |
| `hybrid_sim.m` | Generic hybrid simulator: `ode45` with event functions for the guards on the state, sampled guards every Ts = 5 ms, resets and mode changes. |
| `fr_*.m`, `run_q31.m`, `plot_q31.m` | Hybrid automaton of Q3.1: modes, inputs, guards, resets, simulation and figures. |
| `sq_*.m`, `run_q32.m`, `plot_q32.m` | Hybrid automaton of Q3.2: homing with the Q2.2 detector, then the four sides of the square. |
| `axis_ff.m`, `track_axes.m`, `ellipse_ref.m`, `quintic_coeffs.m`, `quintic_eval.m`, `motor_sensors.m` | Helpers: feed-forward of Q1.4, references and motor sensors. |

Part 3 uses `part-2/park_detector_step.m`. `params_printer.m` adds that path automatically, so nothing has to be set by hand.

## How to run

Each part runs on its own. Open MATLAB in the folder of the part, or `cd` into it, and run its script:

| Part | Folder | Command | Output |
|---|---|---|---|
| Q1.4 | `part-1` | `q1_4` | Figure with the ellipse, the star and the motor voltages |
| Q1.6 | `part-1` | `q1_6` | Figure with the filament temperature |
| Q2 | `part-2` | `main_part2` | Runs of the Moore machine and of the detector, printed in the Command Window |
| Q3 | `part-3` | `main_part3` | Event tables of Q3.1 and Q3.2 in the Command Window; figures saved as PDF in `part-3/figures/` |

The scripts start with `clear`, `clc` and `close all`.

`main_part3` simulates about 112 s of printing for Q3.1 and 30 s for Q3.2. The figures are made invisible and saved directly to `part-3/figures/`. That folder is created automatically and is not tracked by git.

## Expected results (Part 3)

- **Q3.1.** The spool finishes at t = 2.02 s (event F) and printing resumes at about t = 49.1 s. A new colour is required at t = 60 s (event C), so the replacement runs a second time. The maximum contour error after resuming is about 1e-8 mm.
- **Q3.2.** Homing ends at t = 5.33 s. Corner A is reached at 9.335 s and the four sides end at 13.340, 17.345, 21.350 and 25.355 s. All sides are 100 mm long, with a deviation below 0.03 µm.
