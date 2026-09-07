# Simulink package validation

Date: 7 September 2026

Environment: MATLAB and Simulink R2024b on Windows

This check was run against the staged public package after replacing the model workspace's private absolute parameter-file path with the relative filename `Drone_parameters.m`. The original source workspace was not modified.

## Integrated behavioural validation

Command, run from `simulation/`:

```matlab
run(fullfile(pwd,"tests","validate_guidance_features.m"))
```

Result: `Validation passed: 1`.

The run covered the configured Auto zero-yaw and nonzero-yaw cases, Position Hold, manual attitude, deterministic repeated noise, disturbances, the combined scenario, finite values and the 12.5 N per-motor limit. Its numeric outputs matched the values recorded in `SYSTEM_VALIDATION_REPORT.md`.

MATLAB printed `omCallMethod failed on slmsgviewer.removeTab` during shutdown after the result. The batch process exited with code 0 and no validation assertion failed; the message is retained here as a nonfatal environment/UI cleanup observation.

## 3-D demonstration and coordinate validation

Commands, run in order from `simulation/`:

```matlab
run(fullfile(pwd,"scripts","run_3d_visualization.m"))
run(fullfile(pwd,"tests","validate_3d_visualization.m"))
```

Result: `Visualisation validation passed: 1`.

The run produced 3,094 samples, ended at approximately `[4, 2, 1]` m and 30 degrees yaw, and reported:

- maximum rotation orthogonality error: `3.48e-16`;
- maximum displayed/plant thrust-axis error: `0`;
- final yaw error: `0` degrees.

## Repository checks

- The textual contents of the packaged `.slx` contain no private absolute workspace path.
- The model workspace references `Drone_parameters.m` relatively.
- The original model and parameter files retained their pre-packaging SHA-256 hashes.
- Generated `.mat`, video, cache and archive outputs are excluded from the commit.

These checks validate the packaged simulation under the configured scenarios. They do not validate the physical aircraft or establish a calibrated model.
