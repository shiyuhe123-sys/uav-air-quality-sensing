# Unresolved manual-descent event

The existing log contains a transient near **68.44 s**, with a logged upward
velocity change of approximately **0.99 m/s in 0.10 s**. The model did not
reproduce it. Two IMUs support the event, but shared mounting and estimator
dependencies prevent a unique physical attribution.

| Check | Finding from the existing investigation |
|---|---|
| Command logging | About 10 Hz commands and 25 Hz IMUs cannot recover or exclude a between-sample throttle event. |
| Throttle/thrust mapping | An ascent-selected curve improved ordinary response but did not reproduce the pulse. |
| Descent airflow | Declared smooth force sensitivities did not explain the jump; aircraft-specific aerodynamics remain unidentified. |
| Mounting and attitude | Rigid lever-arm and small tilt sensitivities could not explain the full jump under the tested assumptions; shared or soft-mount effects remain unresolved. |
| Timing and filtering | An ascent-selected lag/shift reached grid boundaries and still failed on descent. That candidate was not installed as a verified correction. |
| Manual/autonomous boundary | Fresh post-event initialization reduced error but did not meet the retained criteria. It does not repair a continuous trajectory. |

The investigation used frozen physical coefficients and preserved the failed
comparisons. Excluding the event's scored rows did not remove the subsequent
state error. Neither a time-specific impulse nor discarded disagreement was
used to present a repaired full flight.

The active [RTL demonstration](RTL_PORTFOLIO_SCOPE.md) is a separately stated
conditional comparison. Stabilize/Loiter and whole-flight results remain
unresolved; a close RTL fit does not demonstrate transferable aircraft physics.
The underlying grids, raw pulse streams and full diagnostic MAT files remain
in the private source evidence; this public page is a summary of those checks,
not a newly rerun full diagnostic campaign.
