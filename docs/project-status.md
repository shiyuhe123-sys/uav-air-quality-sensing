# Project status

Last reviewed: 7 September 2026.

This page separates the current engineering record from planned work. It will be updated when evidence is added or a test changes the supported conclusions.

## Physical aircraft

Current source records describe a Tarot 650 Sport quadcopter with DYS D4215 650KV motors, Hobbywing XRotor Pro 50 A ESCs, 12-inch two-blade propellers, a 6S battery, Pixhawk 6C, M10 GPS/compass, ExpressLRS receiver and a DroneCAN-configured power monitor.

Assembly, power and signal wiring, motor assignment and direction, GPS/compass calibration, radio calibration and pre-arm configuration are recorded as complete. A stationary startup and initial log review were reported on 7 September 2026. The current battery-included mass is only an approximate 2.6–2.8 kg.

The final sensor mount and inlet are incomplete. The aircraft has not yet completed a test flight. Final payload mass, centre of gravity, installed-propeller current, hover performance, endurance, vibration and thermal behaviour are therefore unknown.

## Simulation

The source project contains a nominal six-degree-of-freedom MATLAB/Simulink model with cascaded position, altitude and attitude control; four motor models; force and torque disturbances; deterministic sensor noise; three preselected flight modes; yaw-aware position mapping; and 3-D visualisation.

The canonical model, parameter source, supporting scripts, validation scripts, selected technical documentation and selected screenshots are packaged under `simulation/`. Existing project records report successful defined validation scenarios. Both packaged validation workflows were rerun successfully in MATLAB/Simulink R2024b on 7 September 2026; details are in the [package validation record](../simulation/docs/PACKAGE_VALIDATION.md). Model parameters remain nominal and have not been calibrated using physical-flight data.

## Environmental sensing

The project motivation, literature synthesis and staged experimental approach exist in the private source workspace. No public sensor specification, completed mount, synchronized dataset, sensor-bias experiment, vertical profile or sparse 3-D particle map is currently present here.

## Status definitions

| Label | Meaning |
|---|---|
| Completed | Supported by an artefact or explicit project record. |
| Reported | Recorded by the builder, with public evidence still to be packaged or reviewed. |
| Simulated | Produced using the nominal software model. |
| Pending | Not yet completed or evidenced. |
