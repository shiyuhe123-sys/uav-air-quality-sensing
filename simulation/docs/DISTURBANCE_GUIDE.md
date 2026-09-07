# Switchable disturbances

Set `disturbances_enabled = 1` in `Drone_parameters.m`, run `reload_drone_parameters`, and simulate. Set it back to 0 for the nominal model.

| Time (s) | Disturbance | Amplitude |
|---:|---|---:|
| 10-11 | +x world force | 1 N |
| 15-16 | +y world force | 1 N |
| 20-21 | +z world force | 0.5 N |
| 25-25.5 | +roll torque | 0.01 N m |
| 30-30.5 | +pitch torque | 0.01 N m |
| 35-35.5 | +yaw torque | 0.002 N m |

Each pulse is the sum of an On Step and an equal negative Off Step. Forces enter before inverse mass; torques enter before inverse inertia.

The 60-second validation finished at `[x y z phi theta psi] = [3.9999996 1.9999994 1.0000284 4.6719577e-07 -6.1798934e-09 -7.3514517e-15]`. Maximum actual motor thrust was 9.0856593 N against the 12.5 N limit. Validation status: **true**.
