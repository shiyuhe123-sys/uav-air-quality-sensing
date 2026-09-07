# Roadmap

Progress is controlled by evidence gates rather than target dates. A later stage should not be presented as complete until its inputs and results are reviewable.

## 1. Repository foundation — complete

- Establish public structure, status language and contribution rules.
- Define the boundary between publishable evidence and private source material.
- Keep hardware, simulation and planned experiments clearly separated.

Completion gate: clean Git history, relative documentation links and no private or generated source material.

## 2. Package the Simulink model — packaged

- Add the canonical model, parameter source, run scripts and validation scripts.
- Add selected technical documentation and useful screenshots.
- Record the known MATLAB release and required products after verification.
- Explain what the configured validation establishes and what it does not.

Completion gate: a new reader can locate the model and follow the documented run procedure. The saved validation report is included, and a documented MATLAB/Simulink R2024b rerun was completed during repository packaging; this validates the packaged nominal simulation configuration only. It does not validate or calibrate the model against the physical aircraft.

## 3. Document hardware and research — documented

- Add a reconciled as-built hardware status and BOM.
- Replace obsolete wiring guidance with the verified final power and signal architecture.
- Add a concise research motivation, literature synthesis and staged methodology.
- Defer photographs until metadata and content review are complete.

Completion gate: the public record has one current hardware status, describes the PM08-CAN power/CAN architecture and its unresolved as-built connector details, and labels planned sensor work clearly. The public record does not claim that the physical aircraft has flown.

## 4. Prepare flight testing — prepared

- Add configuration, pre-test and flight-test record templates.
- Define fields for mass, centre of gravity, battery, payload, conditions, logs, observations and limitations.
- Define a repeatable log-review checklist.

Completion gate: the repository can record a flight without implying that one has already occurred.

The preparation gate is complete: the repository contains blank aircraft-configuration, pre-flight, first-flight, log-review and evidence-register templates. No physical flight is implied by their presence.

## 5. Add reviewed physical evidence — future

- Add flight results only after raw logs, configuration and analysis have been reviewed.
- Verify payload logging and timestamp alignment before measurement flights.
- Progress from repeatability and placement checks to vertical or spatial mapping only when earlier gates pass.

Completion gate: every public result links to its configuration, processing method and limitations.

Possible later work includes model calibration, robustness analysis, sensor-response modelling, sparse 3-D mapping and adaptive resampling. These are not current project achievements.
