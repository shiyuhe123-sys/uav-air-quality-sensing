# Quadrotor 3-D visualisation

## Architecture

`Visualization_Output` is a one-way sink connected to the six true plant states:

```text
[x, y, z, phi, theta, psi] -> State_Vector -> flight_visualization
```

It does not feed any controller or plant input. The simulation therefore produces the same flight whether the animation is used or not. The subsystem writes one six-column `timeseries` into the simulation output.

`run_3d_visualization.m` runs a demonstration simulation and passes the resulting timeseries to `animate_drone_3d.m`. The animation uses only core MATLAB graphics, because Simulink 3D Animation and UAV Toolbox are not installed.

## Coordinate and attitude convention

The world display uses x, y, and positive-up z coordinates. The quadrotor is rotated from its body frame into the world frame with

```text
R = Rz(psi) * Ry(theta) * Rx(phi)
```

This is the same ZYX yaw-pitch-roll convention used by the dynamics. The third column of this matrix is

```text
[cos(psi)sin(theta)cos(phi) + sin(psi)sin(phi)
 sin(psi)sin(theta)cos(phi) - cos(psi)sin(phi)
 cos(theta)cos(phi)]
```

which matches the model's validated x, y, and vertical thrust projections. This check prevents a common animation error where the vehicle looks correct at zero yaw but rotates or translates along the wrong display axis at nonzero yaw.

## Running it

Open and run `run_3d_visualization.m`. The default demonstration uses:

- flight mode 3;
- the existing 4 m x, 2 m y, and 1 m altitude commands;
- a 30 degree yaw command;
- all configured disturbance pulses;
- ideal sensor feedback for a clear first animation.

The script saves simulation data to `outputs/validation/visualization_last_run.mat` and the final frame to `outputs/images/flight_visualization_preview.png`. Set `visual_record_video = 1` in `model/Drone_parameters.m` to also create `outputs/quadrotor_flight.mp4`.

Run `validate_3d_visualization.m` to check the saved data shape, finite values, increasing timestamps, final target, rotation-matrix orthogonality, and exact agreement between the displayed body z axis and the plant's thrust-direction equations.

## Display parameters

- `visual_frame_rate`: rendered frames per second.
- `visual_playback_speed`: simulated seconds shown per real second.
- `visual_arm_length`: size of the display symbol; this does not change vehicle physics.
- `visual_trail_length`: seconds of recent trajectory left visible.
- `visual_demo_stop_time`: demonstration simulation duration.
- `visual_demo_yaw`: automatic-mode yaw command.
- `visual_demo_disturbances`: enables the disturbance sequence for the demonstration.
- `visual_demo_sensor_noise`: enables sensor noise for the demonstration.
- `visual_record_video`: enables MP4 export.

The red arm represents the body x axis, the blue arm represents the body y axis, and the orange line points along positive body x. The green marker is the commanded x/y/z position.
