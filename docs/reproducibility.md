# Reproducibility

The current public package was checked with MATLAB/Simulink **R2024b on
Windows on 7 October 2026**. Other releases are unverified. Simulink Test,
UAV Toolbox and Simulink 3D Animation are not required by these workflows.

## Active RTL comparison

From the repository root in MATLAB:

```matlab
addpath(fullfile(pwd,'simulation','scripts'));
run_rtl_portfolio_demo('verify');
run_rtl_portfolio_demo('animate');
```

The runner builds timeseries/Dataset inputs from the committed derived CSVs,
applies the frozen configuration through SimulationInput to `Drone_Response_v5`,
and runs exactly 9.284754 s. It checks all eight native-time metrics, reference
sample counts, final simulation time and saved trajectory. Generated metrics
and the verification summary go under ignored `simulation/outputs/`.

The animation uses the committed saved trajectory and reference samples;
it can run without simulating. The raw log is not needed for either public
RTL entry point. [Evidence provenance](../simulation/evidence/rtl/README.md)
defines coordinate conventions and the derived publication subset.

## Original educational model

```matlab
run(fullfile(pwd,'simulation','tests','validate_guidance_features.m'));
run(fullfile(pwd,'simulation','scripts','run_3d_visualization.m'));
run(fullfile(pwd,'simulation','tests','validate_3d_visualization.m'));
```

The 3-D validation consumes the output of the preceding visualisation script.
These defined simulation scenarios are distinct from the flight comparison.
The September [package validation](../simulation/docs/PACKAGE_VALIDATION.md)
is retained as history; the [October package check](../simulation/docs/PUBLIC_PACKAGE_VALIDATION.md)
records the current portable package.

## Optional raw-log import

Python with `pymavlink` is required only for DataFlash import. Add the scripts
path and call `run_day1_flight_import("path/to/flight.bin")`. Generated data
can contain geographic coordinates and are ignored under
`simulation/data/processed/` and `simulation/outputs/`. The original log is
unchanged. The latest explicit-window input preparation source is also
included for future supplied logs.

Full raw-log processing, prior tuning grids and manual-descent diagnostics
were not rerun during this repository update; their findings are recorded as
source-project history. No independent-flight validation is claimed.

## Public checks

Relative links are checked against the combined new and existing repository
files. Native CSV sample counts and selected RMSE values are independently
recalculated. Model ZIP integrity and private-path patterns are checked.
Selected plots and the 3-D still are visually inspected. Generated caches,
raw logs, private correspondence and geographic origins are excluded.
