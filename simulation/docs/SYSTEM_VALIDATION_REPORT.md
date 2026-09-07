# Quadrotor system validation report

## Scope

This validation checks the integrated quadrotor model after the disturbance, sensor, flight-mode, yaw-aware control, parameterisation, and layout changes. Tests use `Simulink.SimulationInput` overrides, so the saved parameter values are not changed by a test case.

The installed MATLAB environment does not provide the `sltest.testmanager` API required by the Simulink Test runner. The tests therefore use deterministic simulations with explicit numerical assertions, following the documented fallback for installations without Simulink Test.

## Acceptance criteria

- The model has no unconnected ports or dangling lines and compiles without errors.
- Automated and position-hold cases finish within 0.1 m or 0.1 rad of the commanded x, y, z, and yaw values.
- Stabilize mode finishes within 1 degree of the commanded roll, pitch, and yaw values and within 0.1 m of its altitude reference.
- Repeating the sensor-noise case with the same seeds produces a final-state difference below `1e-10`.
- Motor thrust remains at or below the configured 12.5 N limit.
- All logged final states and motor values remain finite.

## Results

| Test | Final state or key result | Result |
|---|---|---|
| Structural model check | No unconnected ports, dangling lines, or Stateflow issues | Pass |
| Compile and smoke simulation | Model update and 2 s nominal simulation completed | Pass |
| Mode 3, zero yaw | x=4.000000 m, y=2.000000 m, z=1.000000 m, yaw approximately 0 degrees | Pass |
| Mode 3, yaw-aware control | x=4.000000 m, y=2.000000 m, z=1.000000 m, yaw=45.000000 degrees | Pass |
| Mode 2, position hold | x=1.000000 m, y=-1.000000 m, z=0.799991 m, yaw=20.000000 degrees | Pass |
| Mode 1, Stabilize | roll=3.000000 degrees, pitch=-1.999638 degrees, z=0.745203 m, yaw=10.000000 degrees | Pass |
| Sensor noise enabled | x=3.999649 m, y=2.000649 m, z=1.000686 m, yaw=0.014131 degrees | Pass |
| Seed repeatability | Repeated noisy run had zero final-state difference | Pass |
| All disturbances enabled | x=4.000000 m, y=2.000000 m, z=1.000005 m, yaw approximately 0 degrees | Pass |
| Combined yaw, noise, and disturbances | x=3.999092 m, y=1.999077 m, z=1.000746 m, yaw=30.023201 degrees | Pass |
| Combined-case motor demand | Maximum motor thrust 10.513925 N; limit 12.5 N | Pass |

## Interpretation

The position, altitude, attitude, yaw, motor, disturbance, and sensor paths work together under the tested conditions. The yaw-aware mapping preserves the original zero-yaw response and also reaches the same world x/y targets at nonzero yaw. The sensor model is deterministic when its seeds are unchanged, and its shaped noise does not destabilise the existing continuous PID loops at the saved noise levels.

The large x/y displacement in the Stabilize test is expected. That mode commands a constant nonzero roll and pitch and intentionally bypasses horizontal position hold. The altitude error of approximately 0.055 m remains inside the stated tolerance; it results from the simple altitude loop operating while the vehicle is continuously tilted.

## Limits of this validation

- Flight modes were selected before each simulation. Transitions between modes during a run, controller-integrator resets, and bumpless transfer are not yet implemented.
- The sensor model covers additive, band-limited noise. Bias drift, quantisation, delay, dropouts, and state estimation are not yet modelled.
- The tests cover the configured disturbance pulses and command ranges. They are not an exhaustive flight-envelope or robustness analysis.
- The next 3D visualisation phase should consume the true x/y/z and roll/pitch/yaw signals and must preserve the existing controller feedback paths.

The repeatable test procedure is in `tests/validate_guidance_features.m`; complete numeric traces are saved in `outputs/validation/guidance_sensor_validation.mat`.
