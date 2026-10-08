# Active RTL demonstration

Closed-loop tracking of one flight's recorded internal RTL targets in a
six-degree-of-freedom model, initialized once at **69.920343 s** and stopped
at **79.205097 s**. The model feeds back its own simulated states. Future
logged trajectory is used only for comparison.

Altitude RMSE is **0.09967 m**, GPS horizontal vector RMSE **0.21418 m**,
climb-rate RMSE **0.08882 m/s**, and maximum altitude error **0.17831 m**.
Native scoring uses 92 CTUN and 46 GPS samples. The eight-component score is
**7.363/10**, below the original 8/10 target.

From the repository root in MATLAB:

```matlab
addpath(fullfile(pwd,'simulation','scripts'));
run_rtl_portfolio_demo('verify');
run_rtl_portfolio_demo('animate');
```

The public runner uses [committed derived inputs](../evidence/rtl/README.md),
so it does not need the raw flight log. It applies SimulationInput overrides
to the packaged v5 model and compares the rerun against the saved original
trajectory and all eight native-time metrics. Use this entry point for the
active scope; the model's embedded historical defaults are not the RTL-only
experiment.

See [portfolio plots and animation](../../portfolio/case-study.md) and the
[manual-descent investigation](MANUAL_DESCENT_LIMITATION.md). Prior gain
selection, one inspected flight, logged initialization and estimator references
constrain the result. Independent-flight and whole-flight prediction remain
unverified. The real aircraft uses ArduCopter; this controller is not deployed.
