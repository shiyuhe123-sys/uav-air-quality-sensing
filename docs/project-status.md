# Project status

Last reviewed: 7 October 2026; flight and portfolio evidence through 4 October.

## Physical aircraft

The Tarot 650 Sport build integrates four DYS D4215 650KV motors, Hobbywing
XRotor Pro 50 A ESCs, 12-inch two-blade propellers, a 6S battery, Pixhawk 6C,
M10 GPS/compass, ExpressLRS receiver and a configured DroneCAN power monitor.
Assembly, wiring, motor direction and calibration are recorded as complete.
The latest builder-reported flight mass is approximately **3 kg**, superseding
the earlier 2.6–2.8 kg estimate. Final mass and centre of gravity with the
completed sensing payload remain pending.

The first physical flight was recorded on **28 September 2026**. Its DataFlash
log was processed locally into 61,814 records across 74 message types. The
roughly 105-second recording includes non-airborne periods. See the
[first-flight analysis](../flight-testing/first-flight-analysis.md) for the
public record and its limits. The raw log and precise location remain private.

The final sensor mount/inlet and environmental measurement campaign remain
unfinished. One flight does not establish repeatable endurance, final-payload
performance, airworthiness or sensing accuracy. Exported as-built connector
and parameter details remain outside this public package.

## Simulation and flight comparison

The [original educational model](../simulation/README.md) remains available
with its tests, documented September package validation and default-off replay
interface. It has position/altitude/attitude control, motor mixing, actuator
dynamics, noise, disturbances, flight modes and 3-D outputs.

The active demonstration uses the separate **Drone_Response_v5** model:
conditional closed-loop tracking of recorded RTL targets from **69.920343 to
79.205097 s**, initialized once from logged state. The model uses simulated
state feedback. Future measured state is a comparison reference, not a
continually injected correction.

| Native-time metric | Result |
|---|---:|
| CTUN altitude RMSE | 0.09967 m |
| GPS horizontal vector RMSE | 0.21418 m |
| CTUN climb-rate RMSE | 0.08882 m/s |
| Maximum altitude error | 0.17831 m |
| Roll / pitch RMSE | 1.2416° / 1.3185° |
| Project-specific score | 7.363/10; original 8/10 goal unmet |

There are 92 native CTUN and 46 native GPS reference samples. The previous
RTL-only rerun matched its frozen parent within 4.36e-7 in the six state
channels. A small [public derived dataset](../simulation/evidence/rtl/README.md)
now supports a portable regression check without the raw log.

Six manual-descent checks did not establish a transferable correction for the
event near 68.44 s. Stabilize/Loiter and continuous-flight comparisons remain
unresolved diagnostics. [Failure investigation](../simulation/docs/MANUAL_DESCENT_LIMITATION.md)
records the findings. Prior tuning, one inspected flight, provisional physics
and estimator references constrain the interpretation. Whole-flight and
independent-flight prediction remain unverified. The aircraft uses ArduCopter;
the Simulink controller has not been deployed to it.

## Environmental sensing

The [research methodology](../research/methodology.md) remains a staged plan.
There is no completed payload dataset, sensor-bias experiment, vertical
profile or sparse 3-D particle map. Sensor selection/configuration, mount,
timestamp alignment and repeatability require further evidence.

## Public package

The repository includes the hardware/research record, flight templates,
first-flight summary, original model and latest RTL model, portable RTL
inputs/references, processing source, native-time plots, GIF/video and
[updated case study](../portfolio/case-study.md). Private correspondence,
raw logs, geographic origins, third-party PDFs, caches and development archives
are excluded. [Reproducibility](reproducibility.md) distinguishes recorded
source-workspace results from verification of this public package.
