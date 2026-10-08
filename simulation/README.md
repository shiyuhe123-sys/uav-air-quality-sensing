# Quadrotor simulation and flight-log comparison

This package contains a nominal six-degree-of-freedom quadrotor model for learning, controller development and repeatable simulation experiments. It is related to the physical air-quality UAV through the broader project motivation, with nominal educational parameters. The separate v5 experiment uses selected same-flight coefficients and recorded targets; it is not a comprehensively identified aircraft model. Neither controller is deployed to the Pixhawk.

![Simulink model overview](images/Drone_simulation_overview.png)

## Active RTL comparison

The separate `model/Drone_Response_v5.slx` and public derived inputs reproduce
the latest conditional same-flight RTL comparison. From the repository root:

```matlab
addpath(fullfile(pwd,'simulation','scripts'));
run_rtl_portfolio_demo('verify');
run_rtl_portfolio_demo('animate');
```

The raw log is unnecessary for this demo. See [exact scope](docs/RTL_PORTFOLIO_SCOPE.md),
[input provenance](evidence/rtl/README.md), [manual-descent limitation](docs/MANUAL_DESCENT_LIMITATION.md)
and [package verification](docs/PUBLIC_PACKAGE_VALIDATION.md). Altitude/horizontal
RMSE: 0.09967/0.21418 m over 9.284754 s; 7.363/10 remains below the original
target. Whole-flight and independent-flight prediction are unresolved.

The original model includes a default-off measured-command replay interface.
The sections below describe its educational simulation and existing tests.

## Included scope

- translation in x, y and z and rotation in roll, pitch and yaw;
- cascaded horizontal-position, altitude and attitude control;
- four-motor mixing and four first-order motor/propeller models;
- switchable external force and torque disturbances;
- six-channel deterministic, band-limited sensor noise;
- Stabilize/manual-attitude, Position Hold and Auto command modes;
- yaw-aware conversion from world-frame position commands to body roll/pitch commands;
- a one-way true-state output for 3-D animation.

The model uses SI units and radians internally. Its mass, inertia, thrust, motor and controller values are nominal educational values retained for reproducibility.

## Architecture

```mermaid
flowchart LR
    R[Command references] --> F[Flight mode manager]
    F --> P[Position and altitude control]
    P --> A[Attitude control]
    A --> M[Mixer and four motor models]
    M --> D[Six-DOF dynamics]
    X[Force and torque disturbances] --> D
    D --> T[True states]
    T --> S[Sensor model]
    S --> P
    S --> A
    T --> V[3-D visualisation output]
```

The visualisation path does not feed the controller or plant. Further subsystem views are available in [images](images/).

## Requirements

The saved development record identifies:

- MATLAB R2024b;
- Simulink R2024b;
- Windows.

The model may work in other releases, but that has not been checked. Simulink Test is not required by the included assertion-based scripts. The animation uses MATLAB graphics and does not require Simulink 3D Animation or UAV Toolbox according to the saved project record.

## Open and run the model

Start MATLAB in the repository root, then run:

```matlab
modelFile = fullfile(pwd,"simulation","model","Drone_simulation.slx");
open_system(modelFile)
```

The model workspace loads values from [`model/Drone_parameters.m`](model/Drone_parameters.m). Edit that file to change the configured scenario. If the model is already open after an edit, reload it with:

```matlab
run(fullfile(pwd,"simulation","scripts","reload_drone_parameters.m"))
```

Parameter definitions and flight-mode settings are described in the [parameter guide](docs/PARAMETER_GUIDE.md) and [guidance, sensor and flight-mode guide](docs/GUIDANCE_SENSOR_FLIGHT_MODES_GUIDE.md).

## Validation

Run the integrated behavioural checks from the repository root:

```matlab
run(fullfile(pwd,"simulation","tests","validate_guidance_features.m"))
```

The script loads the canonical model, applies scenario variables through `Simulink.SimulationInput`, checks structural assumptions and evaluates explicit numerical assertions. It writes generated results below `simulation/outputs/validation/`; these binary files are intentionally ignored by Git.

The existing [system validation report](docs/SYSTEM_VALIDATION_REPORT.md) records the acceptance criteria, configured results and limitations from the source workspace. Both packaged validation workflows were rerun successfully in MATLAB/Simulink R2024b on 7 September 2026; see the [package validation record](docs/PACKAGE_VALIDATION.md). These checks establish behaviour only for their defined simulations; they do not demonstrate physical-flight performance, full-envelope robustness or calibration to the Tarot aircraft.

Additional focused documentation:

- [disturbance model](docs/DISTURBANCE_GUIDE.md);
- [y-translation physics review](docs/Y_TRANSLATION_PHYSICS_REVIEW.md);
- [3-D visualisation](docs/3D_VISUALIZATION_GUIDE.md);
- [package validation record](docs/PACKAGE_VALIDATION.md).

## 3-D demonstration

Generate the demonstration output, then validate its coordinate convention:

```matlab
run(fullfile(pwd,"simulation","scripts","run_3d_visualization.m"))
run(fullfile(pwd,"simulation","tests","validate_3d_visualization.m"))
```

The second command expects `visualization_last_run.mat` from the first command. Video recording is disabled by default and can be enabled in the parameter file.

![3-D flight visualisation](images/flight_visualization_preview.png)

## Package map

- [`model/Drone_simulation.slx`](model/Drone_simulation.slx) â€” canonical Simulink model.
- [`model/Drone_parameters.m`](model/Drone_parameters.m) â€” single model-workspace parameter source.
- [`scripts/`](scripts/) â€” parameter reload and 3-D demonstration utilities.
- [`tests/`](tests/) â€” deterministic assertion-based validation scripts.
- [`docs/`](docs/) â€” model behaviour, parameters and validation interpretation.
- [`images/`](images/) â€” selected current model and visualisation screenshots.

Development snapshots, caches, autosaves, generated `.mat` outputs and archived layout images are deliberately excluded.


## Optional raw-log processing

Python with `pymavlink` is required only for DataFlash import. In MATLAB, after
adding the scripts path, call `run_day1_flight_import("path/to/flight.bin")`.
It writes generated data under ignored `simulation/data/processed/` and
`simulation/outputs/`; those files can contain precise GPS positions and are
excluded from the public package. `prepare_response_airborne_inputs` and
`response_initial_rates` retain the latest explicit-window input preparation
for future supplied logs; independent-flight accuracy must be evaluated.
