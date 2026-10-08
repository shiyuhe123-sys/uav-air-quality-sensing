# Public RTL evidence

Source: the frozen RTL-only result from the 28 September 2026 flight, exported
on 7 October 2026. The simulation interval is 69.920343–79.205097 s (9.284754 s).

This small derived dataset is included to substantiate and reproduce the
featured comparison. GPS is expressed only as local North/East displacement;
latitude, longitude, geographic origin, raw log, device identifiers and private
workspace paths are excluded.

- `configuration.json`: frozen coefficients, one initial state, score criteria and expected metrics.
- Command CSVs: time in seconds relative to initialization, followed by SI values; attitude is radians, collective is normalized, acceleration is positive Up. `ManualEnable` uses zero-order hold.
- `GPS.csv`, `CTUN.csv`, `ATT.csv`, `EKFVelocity.csv`: native-rate reference samples. ATT is in degrees; EKF VN/VE/VD is NED. Only the reference timestamps are used for scoring.
- `AnimationATT.csv`: attitude converted to the model's positive-Up convention, in radians.
- `frozen-trajectory.csv`: saved simulation time, North/East/Up in metres and roll/pitch/yaw in radians. Animation interpolation does not add measurements.
- `summary.json`: authoritative saved RTL score and rerun comparison.

Run `run_rtl_portfolio_demo('verify')` using the simulation scripts path. The
runner checks all eight metrics, native sample counts, duration and trajectory
against the original saved evidence. It uses its own simulated state feedback;
the measured future trajectory is used for comparison only.

The result remains a same-flight conditional tracking test after prior gain
selection and inspection. CTUN and EKF are estimator references. The original
8/10 project goal was not reached; neither independent-flight accuracy nor
whole-flight prediction is established.
