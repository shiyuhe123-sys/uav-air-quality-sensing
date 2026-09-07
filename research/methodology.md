# Planned experimental methodology

Every stage in this document is planned. It must not be read as evidence that the corresponding experiment has already been completed.

## Stage 1 — Payload and data definition

Before flight testing, record the sensor model, payload mass, power requirements, inlet arrangement, intended mounting positions and storage format. The target row structure is provisional and depends on the selected instrument:

```text
time, x, y, z, instrument-supported particle metrics, instrument-supported PM fields, temperature, humidity, pressure/altitude, flight state
```

Record the timestamp basis, sampling interval, units, missing-data representation and any clock offset. Keep raw recordings separate from processed files.

Particle-size bins and PM values must not be assumed for every candidate sensor. After selection, record the actual channels, size ranges, units, detection limits, averaging behaviour and any unavailable fields. If the instrument does not provide a requested field, mark it as unavailable rather than reconstructing it from an unsupported proxy.

## Stage 2 — Bench logging and sensor checks

Verify that the sensor produces a recoverable recording with known units and timestamps. Estimate short-term repeatability and response behaviour where practical. Log temperature and humidity so later quality flags can be defined. If a fixed reference instrument is available, co-location can provide relative context; without one, report repeatability rather than absolute accuracy.

## Stage 3 — Mount characterization

Compare at least two candidate sensor positions, such as a body-mounted position and a boom or separated position, subject to safe mechanical design. Record mount geometry, retention, clearance, mass and the resulting centre-of-gravity configuration. A placement that appears higher or more exposed should be treated as a hypothesis until measurements support it.

## Stage 4 — First-flight baseline

Use a conservative, permitted test plan to establish the aircraft baseline before beginning a measurement campaign. Record the exact aircraft, battery, payload and software configuration. Review the raw log and post-test observations for power demand, vibration, attitude response, motor demand, temperatures and failsafe behaviour. A flight without the final sensor payload is an unloaded baseline and does not validate the loaded aircraft.

## Stage 5 — Sampling-bias comparisons

After the aircraft and payload pass earlier gates, compare a small number of controlled conditions:

- motor-off versus motor-on where safe and meaningful;
- one sensor position versus another;
- hover versus slow forward motion; and
- repeated runs along the same route or at the same test points.

Define the comparison and acceptance criterion before each test. Report differences, spread, environmental conditions and any reference measurement. Sequential changes in concentration alone cannot establish a propeller-flow effect, so interpret the result conservatively.

## Stage 6 — Baseline vertical profiles

If permitted by the site and operating requirements, repeat structured vertical profiles at defined heights. Treat this as a platform and baseline demonstration, not the central novelty claim. Include the particle metrics actually supported by the selected instrument, together with temperature, humidity, wind/context observations and the number of repeats. Do not publish a profile as a result until the raw data, configuration and processing are reviewed.

## Stage 7 — Sparse 3-D mapping

Define a bounded volume around a simple built-environment feature. Use structured paths such as vertical columns, horizontal slices or facade-parallel passes. Produce a sparse point dataset and 3-D scatter plot coloured by a particle metric. Describe the sampled structure and uncertainty; do not imply that interpolation reconstructs the complete atmospheric field.

## Stage 8 — Optional semi-adaptive resampling

Only after a coarse dataset is trustworthy, use a transparent offline rule to identify high gradients, high concentrations or uncertain regions. A second route may then sample those regions more densely and be compared with a fixed route under a similar sample or time budget. This is an optional future stage, not a current project result or autonomous capability.

## Evidence gate

Each future public result should identify:

- the test ID and configuration;
- the objective and acceptance criterion;
- conditions and any reference instrument;
- raw-data and processing locations;
- units, timestamp handling and quality flags;
- the result and its uncertainty; and
- limitations or anomalies.

Without those records, describe the activity as planned or reported rather than validated.
