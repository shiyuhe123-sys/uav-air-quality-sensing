# Public package verification — 7 October 2026

Environment: MATLAB/Simulink **24.2.0.2712019 (R2024b)** on Windows. The public
stage contains repository-relative paths and does not require the private raw
log for the RTL demonstration. Source models and private evidence were retained.

| Workflow | Outcome |
|---|---|
| Public RTL rerun | Passed: all eight metrics, native sample counts, simulation duration and frozen trajectory regression. |
| Maximum difference in the six state channels | 1.66e-6 against the saved original trajectory; limit 5e-5. |
| Maximum native metric difference | 7.25e-8; limit 1e-5. |
| Reference samples | 46 GPS and 92 CTUN, unchanged. |
| Original guidance checks | Passed: zero/nonzero yaw positioning, position hold, manual attitude, deterministic noise repeatability, disturbances and combined scenario. |
| Combined nominal maximum motor thrust | 10.513925 N against the original configured 12.5 N limit. |
| 3-D output and coordinates | Passed; maximum rotation orthogonality error 3.48e-16 and displayed/plant thrust-axis discrepancy 0. |

The portable runner reconstructs inputs from decimal CSV exports and uses a
finite 9.284754-second simulation. Small numerical differences from the source
MAT evidence are within the stated regression bounds; no gains were retuned.
This is a package reproducibility check, not new experimental validation.

The featured score remains **7.363/10**, below the original 8/10 goal. Manual
descent, whole-flight and independent-flight accuracy remain unresolved.
Optional raw-log import and the prior full diagnostic campaign were not rerun
during this package update; their history is reported separately.

Public preparation also checked repository links, native sample counts,
selected RMSE recalculation, source syntax, private-path patterns and model ZIP
integrity, and visually inspected the selected plots and 3-D still. Raw logs,
geographic origins, private correspondence and generated caches were excluded.
