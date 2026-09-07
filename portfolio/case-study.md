# Air-quality sensing quadcopter and flight simulation

## Project overview

This project combines the integration of a Tarot 650-based quadcopter for a future particle-sensing payload with a separate MATLAB/Simulink quadrotor model. The engineering aim is to develop a modifiable sensing platform and a transparent workflow for investigating how payload placement and aircraft operation may affect measurements around built infrastructure.

The physical aircraft uses a Tarot 650 Sport frame, four DYS D4215 650KV motors, four Hobbywing XRotor Pro 50 A ESCs, a Pixhawk 6C, GPS/compass, ExpressLRS radio and a reported DroneCAN power-monitor configuration. Assembly, wiring and configuration checks are recorded as complete in the source project record. The final sensor mount is still pending, and no physical test flight or air-quality measurement is claimed.

The software package contains a six-degree-of-freedom Simulink model with cascaded position, altitude and attitude control, four motor models, actuator limits, three flight modes, yaw-aware position mapping, deterministic sensor noise, disturbances and 3-D visualisation. The model is nominal and is not deployed to the Pixhawk.

## Engineering problem

An aircraft can reach a measurement location without producing representative particle data. Propeller flow, sensor position, humidity, flight mode, sensor response and time/position alignment can all affect the result. The project therefore treats the aircraft, payload mount, logging path and analysis workflow as one measurement system.

UAV particle profiling and 3-D pollutant measurement already exist in the literature. The planned contribution is narrower: a student-buildable, modifiable platform with practical sampling-bias checks, explicit data-quality handling and sparse particle-size mapping around a defined built-environment feature.

## Evidence available now

### Physical integration

- The current aircraft configuration and component roles are documented in the [hardware record](../hardware/README.md), [BOM](../hardware/bom.md) and [wiring/integration record](../hardware/wiring-and-integration.md).
- Assembly, power and signal wiring, motor assignment and direction, GPS/compass calibration, radio calibration and pre-arm configuration are recorded as complete.
- A stationary startup and initial log inspection were reported, but the logs are not public.
- Reported battery-included mass is approximately 2.6–2.8 kg before the final payload configuration.

These records do not establish physical flight stability, endurance, vibration, thermal performance or air-quality measurement accuracy.

### Simulation

The packaged model and [validation report](../simulation/docs/SYSTEM_VALIDATION_REPORT.md) provide configured simulation evidence. The saved validation covers structural checks, zero- and nonzero-yaw positioning, position hold, manual attitude control, deterministic noise repeatability, disturbances, a combined yaw/noise/disturbance case and a configured motor-thrust limit. The package validation record reports successful reruns in MATLAB/Simulink R2024b on 7 September 2026.

One reported combined simulation case reached a maximum motor thrust of 10.513925 N against a configured 12.5 N limit, and the seeded noise repeatability check produced zero final-state difference in the repeated run. These are results of the nominal simulation scenarios, not measurements of the Tarot aircraft.

## Planned next evidence

The next useful physical evidence is staged:

1. finish and secure the sensor mount and inlet;
2. record final mass and centre of gravity for each payload configuration;
3. conduct a conservative first-flight baseline and review its raw log;
4. verify payload logging, units, timestamps and clock alignment;
5. compare a small number of sensor positions or flight conditions;
6. only then consider repeatability tests, vertical profiles and sparse 3-D mapping.

The planned research methodology documents the gates and limitations for these stages. A loaded flight configuration must not be represented by an unloaded baseline.

## Current limitations

- The final payload mount and inlet are incomplete.
- No physical test flight has been completed.
- Installed-propeller current and thermal behaviour are unmeasured.
- No synchronized particle, meteorological or position dataset is public.
- Sensor calibration, response time, sampling bias and repeatability remain pending.
- The Simulink parameters have not been calibrated against the physical aircraft.
- The Simulink controller is not deployed to the Pixhawk.
- Future maps would be sparse sampled evidence, not a continuous atmospheric field.

## CV wording supported by the current record

The following claims are supported if the work is described accurately:

- Integrated and configured a Tarot 650-based quadcopter with Pixhawk 6C flight control, GPS/compass, ExpressLRS radio and a planned particle-sensing payload.
- Developed a six-degree-of-freedom MATLAB/Simulink quadrotor model with cascaded control, four motor models, three flight modes, deterministic sensor noise, disturbances and 3-D visualisation.
- Built repeatable assertion-based simulation validation for configured guidance, attitude, noise, disturbance and coordinate-consistency scenarios.

## Future wording templates — not achieved claims

Use these only after the relevant evidence exists:

- Characterized flight performance across **[N]** tests for a **[mass] kg** configuration, measuring **[hover power/endurance/vibration metric]**.
- Compared **[N]** sensor positions across **[N]** repeat runs and measured a **[percentage]** difference under **[conditions]**.
- Built a processing workflow aligning **[N]** particle measurements with time and position, with a documented clock uncertainty of **[value]**.
- Produced a sparse 3-D particle-size map over **[volume/site]** from **[N]** reviewed flight runs.

Do not replace the current supported wording until the raw configuration, data, processing method and limitations support the new numbers.
