# Roadmap

Progress is controlled by evidence gates rather than target dates. A later stage should not be presented as complete until its inputs and results are reviewable.

## 1. Repository foundation — current stage

- Establish public structure, status language and contribution rules.
- Define the boundary between publishable evidence and private source material.
- Keep hardware, simulation and planned experiments clearly separated.

Completion gate: clean Git history, relative documentation links and no private or generated source material.

## 2. Package the Simulink model

- Add the canonical model, parameter source, run scripts and validation scripts.
- Add selected technical documentation and useful screenshots.
- Record the known MATLAB release and required products after verification.
- Explain what the configured validation establishes and what it does not.

Completion gate: a new reader can locate the model and follow the documented run procedure; any reported checks are tied to saved evidence or a recorded rerun.

## 3. Document hardware and research

- Add a reconciled as-built hardware status and BOM.
- Replace obsolete wiring guidance with the verified final power and signal architecture.
- Add a concise research motivation, literature synthesis and staged methodology.
- Add selected photographs only after metadata and content review.

Completion gate: no contradictory power-module or build-status instructions remain, and planned sensor work is labelled clearly.

## 4. Prepare flight testing

- Add configuration, pre-test and flight-test record templates.
- Define fields for mass, centre of gravity, battery, payload, conditions, logs, observations and limitations.
- Define a repeatable log-review checklist.

Completion gate: the repository can record a flight without implying that one has already occurred.

## 5. Add reviewed physical evidence — future

- Add flight results only after raw logs, configuration and analysis have been reviewed.
- Verify payload logging and timestamp alignment before measurement flights.
- Progress from repeatability and placement checks to vertical or spatial mapping only when earlier gates pass.

Completion gate: every public result links to its configuration, processing method and limitations.

Possible later work includes model calibration, robustness analysis, sensor-response modelling, sparse 3-D mapping and adaptive resampling. These are not current project achievements.
