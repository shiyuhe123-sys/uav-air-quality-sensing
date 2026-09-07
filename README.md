# UAV Air-Quality Sensing and Quadrotor Simulation

This repository documents a Tarot 650-based UAV being prepared for particle-sensing research and a separate MATLAB/Simulink quadrotor model used to explore flight dynamics and control.

The project treats the aircraft, sensor mounting, data logging and analysis as parts of one measurement workflow. The intended research direction is repeatable, position-referenced particle sensing around built infrastructure, with particular attention to possible sampling interference from the aircraft.

## Project status

| Area | Current status |
|---|---|
| Baseline aircraft | Assembly, wiring, motor-direction checks, GPS/compass calibration, radio calibration and reported pre-arm configuration are complete in the source project records. |
| Sensor mount and inlet | In design; fabrication, installation and final measurement are pending. |
| Bench operation | A stationary startup and initial log inspection have been reported. The logs are not yet included here. |
| Physical flight testing | Not started. No flight-performance result is claimed. |
| Air-quality measurements | Not started. No sensor dataset or spatial map exists yet. |
| Simulink model | An existing nominal six-degree-of-freedom model includes cascaded control, motor models, disturbances, deterministic sensor noise, three flight modes and 3-D visualisation. Packaging is planned for a later repository stage. |
| Simulation validation | Existing project records report passes for defined simulation scenarios. The model has not been calibrated against the physical aircraft. |

The Simulink model is an educational flight-dynamics and control model. It is not a calibrated digital twin, is not deployed to the Pixhawk, and does not control the physical aircraft.

See [project status](docs/project-status.md), [limitations](docs/limitations.md) and the [roadmap](docs/roadmap.md) before interpreting any result.

## Repository structure

```text
hardware/        Aircraft integration, BOM and wiring documentation
research/        Motivation, literature synthesis and experimental methodology
simulation/      MATLAB/Simulink model, scripts, tests and selected evidence
flight-testing/  Configuration and test-record templates; future reviewed results
portfolio/       Concise case-study material derived from supported evidence
docs/            Status, roadmap, evidence policy and reproducibility guidance
```

The folders are placeholders in this foundation stage. Source material will be reviewed and added in later feature branches. Private correspondence, literature PDFs, archives, raw logs, generated caches and GPS-tagged photographs are deliberately absent.

## Evidence language

- **Completed** means an artefact or project record supports the work described.
- **Reported** means the builder recorded that an activity occurred, but the public repository does not yet contain independently reviewable evidence.
- **Simulated** identifies results produced by the nominal Simulink model.
- **Planned** and **pending** describe work that has not been completed.

Simulation results do not establish physical flight performance or sensing accuracy. Planned tests will only be described as results after their configuration, raw evidence and analysis have been reviewed.

## Reproducing the project

Stage 1 contains documentation only. The model, scripts and exact run instructions will be added during the Simulink packaging stage after dependency and path checks. See [reproducibility](docs/reproducibility.md).

## Contributing

Changes should be made on focused feature branches and supported by reproducible evidence. Read [CONTRIBUTING.md](CONTRIBUTING.md) before proposing changes.

## Licence

No public licence has been selected yet. Until a licence is added, the contents remain subject to the default protections of copyright law. Third-party papers, manuals and private correspondence are not part of this repository.
