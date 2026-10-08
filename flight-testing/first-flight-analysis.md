# First-flight analysis: 28 September 2026

The first physical flight produced an ArduPilot DataFlash log. Local processing
imported **61,814 records across 74 message types** into MATLAB native-rate
tables/timetables. The roughly 105-second log includes time outside the
airborne comparison. The latest builder-reported aircraft mass is about 3 kg;
the sensing mount and final payload configuration were incomplete.

## Processing and evidence

The [DataFlash extractor](../simulation/tools/extract_ardupilot_bin.py) uses
Python/pymavlink. The [MATLAB import entry point](../simulation/scripts/run_day1_flight_import.m)
retains native timing, creates local trajectory data and exports plots and
summaries. It accepts a user-supplied raw log path and leaves that log unchanged.
Raw output can contain geographic coordinates and remains in ignored folders.

The public [derived RTL evidence](../simulation/evidence/rtl/README.md) contains
local displacement, commands, one initial state and logged comparison
references. It omits the raw log and geographic origin. The public package is
therefore sufficient for the featured RTL rerun, but not a substitute for the
full original flight log or an independently complete flight-safety record.

## Model comparison

Early same-flight hover/replay comparisons exposed metre-scale drift. Frame
conversion, initialization, reference alignment, force assumptions and simulated
horizontal feedback were investigated. A frozen RTL-only comparison from
69.920343–79.205097 s produced altitude RMSE 0.09967 m, GPS horizontal vector
RMSE 0.21418 m and climb-rate RMSE 0.08882 m/s. The eight-component score was
7.363/10, below the original 8/10 target.

This is conditional closed-loop target tracking using recorded internal targets
and one logged initial state. It is not independent-flight or full-flight
prediction. [Manual-descent diagnostics](../simulation/docs/MANUAL_DESCENT_LIMITATION.md)
remain unresolved. The aircraft itself runs ArduCopter.

## Still required

Record final payload configuration, mass and centre of gravity; review flight
warnings, power, vibration and failsafe behaviour before further controlled
tests; establish repeatability and timestamped payload measurements. One log
does not support sensing accuracy, sensor bias, endurance or general safety
claims. The preparation templates remain blank for future use; they have not
been backfilled to invent missing first-flight observations.
