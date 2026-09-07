# Contributing

This repository is developed through small, reviewable feature branches. The `main` branch represents the latest reviewed state.

## Branch workflow

1. Update from the latest `main` branch.
2. Create a clearly named feature branch such as `docs/...`, `feat/...` or `fix/...`.
3. Keep each commit focused on one purpose.
4. Run the checks relevant to the changed files.
5. Review claims, paths and generated artefacts before merging.

Do not commit directly to `main` for ordinary project work. Do not merge one feature branch into another as a substitute for updating from reviewed `main`.

## Evidence and claims

- Distinguish physical observations from simulation results.
- Label proposed procedures, future work and untested designs as planned or pending.
- Record the configuration, units, software version and acceptance criterion associated with a result.
- Keep raw evidence unchanged. Put scripts and derived results in separate locations.
- Do not claim that the Simulink controller operates the physical aircraft.
- Do not describe the model as calibrated until measured aircraft data and a documented calibration procedure support that statement.

## Public-data review

Before adding a file, check it for credentials, personal information, precise test locations, private correspondence and device metadata. Strip GPS metadata from photographs and retain the original image outside this repository. Replace literature PDFs and third-party manuals with citations or official links unless redistribution rights are clear and inclusion is necessary.

## Generated files

Do not commit MATLAB/Simulink caches, autosaves, generated code, temporary render folders, development snapshots or raw validation datasets. A small derived result may be included when it is required to substantiate a documented claim and its provenance is clear.

## Documentation

Use relative repository paths. A reader should be able to understand the current status without access to local workspaces or prior conversations. Update `docs/project-status.md` and `docs/limitations.md` when a change affects what the project can support.
