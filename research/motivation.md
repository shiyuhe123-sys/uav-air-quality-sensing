# Motivation and research question

## Measurement problem

Particle measurements made from a multirotor aircraft are not automatically representative just because the aircraft can reach a location. Propeller flow, airframe geometry, inlet position, flight mode, humidity, sensor response and clock/position alignment can all affect what the payload records. The aircraft and the sensing workflow should therefore be treated as parts of one measurement system.

UAV-based aerosol and pollutant measurements already exist. Julaha et al. (2025) demonstrate vertical profiling of particle-size distributions and carbonaceous aerosols, while Girdwood et al. (2020) show both the feasibility of carrying an optical particle counter and the importance of aerodynamic and instrument validation. Liang and Shen (2024) demonstrate an integrated UAV platform for three-dimensional pollutant measurements, and Moormann et al. (2025) describe a higher-end flying laboratory with aerosol, trace-gas and meteorological instrumentation. These studies mean that attaching a particle sensor to a drone, flying vertical profiles or making a 3-D pollutant map should not be presented as novel by themselves.

The practical opportunity for this project is narrower: build and document a student-scale platform whose payload arrangement can be modified, test obvious sources of flight-induced sampling variation, and connect the resulting measurements to a simple built-environment geometry. The intended output is sparse, georeferenced evidence with explicit uncertainty and limitations rather than a regulatory-grade continuous pollution field.

## Research question

> Can a student-buildable UAV and modular particle-sensing payload produce repeatable, georeferenced particle-size measurements, quantify major flight-induced sampling biases, and demonstrate sparse 3-D particle-size mapping around a defined built-environment geometry?

## Planned contribution

The planned contribution is an engineering integration and validation workflow combining:

- a modifiable aircraft and payload arrangement designed around sensor access;
- practical comparisons of sensor position, motor state and flight pattern;
- particle, meteorological, time and position records that can be aligned;
- repeatability checks before broader mapping;
- sparse 3-D plots linked to a simple site feature; and
- transparent reporting of what the measurements cannot establish.

This is a planned contribution, not a completed novelty claim. The first priority is to establish that the aircraft, payload and data path operate safely and repeatably enough to justify later experiments.

## Built-environment context

A later demonstration may use a bounded and permitted setting such as a building edge, road-facing facade, sheltered courtyard or another simple geometry. The site should be chosen for safe operation, access and interpretability. A map would represent sampled points within a defined volume; it would not be treated as a perfect continuous atmospheric field.

## Scope boundaries

The project is not currently claiming:

- regulatory air-quality monitoring;
- absolute sensor accuracy without a suitable reference;
- that a custom UAV or vertical profile is new in the literature;
- full computational-fluid-dynamics validation;
- autonomous flight or adaptive resampling; or
- calibration of the Simulink model against the physical aircraft.

Those topics may inform future work, but the current public record contains no flight or sensor dataset.
