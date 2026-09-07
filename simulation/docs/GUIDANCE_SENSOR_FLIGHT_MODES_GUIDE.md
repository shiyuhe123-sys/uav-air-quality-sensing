# Sensor models, flight modes, and yaw-aware position control

This phase adds three ideas to the quadrotor model while preserving the existing automatic waypoint flight as the default:

1. controllers receive measured states through a sensor model;
2. one flight-mode manager selects the active reference source;
3. horizontal position commands are rotated into body roll and pitch commands using measured yaw.

The saved defaults are `flight_mode = 3`, `sensor_noise_enabled = 0`, and `disturbances_enabled = 0`. With those values, the model runs the familiar automatic x/y/z/yaw command scenario without measurement noise or external disturbances.

## 1. Sensor model

### Why add a measurement layer?

An ideal controller reads the exact plant state. A real flight controller reads estimates produced by sensors and filtering. Separating the two signals makes that distinction explicit:

- **true states** are the outputs of the dynamics and are used for scopes and validation;
- **measured states** are the signals returned by `Sensor_Model` and used by all six feedback controllers.

The six channels are x, y, z, roll, pitch, and yaw. Each implements

```text
measured = true + sensor_noise_enabled * shaped_noise
```

The noise source is a seeded normally distributed random sequence. Its variance is `sigma^2`, because the Random Number block asks for variance rather than standard deviation. Each channel has a separate seed, so its sequence is repeatable and independent of the other channels.

The raw random sequence is passed through

```text
              1
G(s) = ----------------
       tau_noise s + 1
```

before it reaches the enable gain. This gives the noise finite bandwidth. It is especially useful here because the existing attitude loops contain derivative action: discontinuous white-noise samples can otherwise create unrealistic derivative kicks. The true signal itself is not filtered, so disabling noise gives the original feedback path exactly.

### Parameters

- `sensor_noise_enabled`: 0 selects ideal measurements; 1 adds noise.
- `sensor_sample_time`: update period of all noise sources.
- `sensor_noise_tau_position`: shaping time constant for x, y, and z noise.
- `sensor_noise_tau_attitude`: shaping time constant for roll, pitch, and yaw noise.
- `sigma_x`, `sigma_y`, `sigma_z`: position standard deviations in metres.
- `sigma_phi`, `sigma_theta`, `sigma_psi`: angle standard deviations in radians.
- `seed_x` through `seed_psi`: deterministic random seeds.

### How to build it yourself

For each state channel:

1. Add an Inport named for the true state and an Outport named for the measured state.
2. Add a Random Number block. Set mean to 0, variance to the square of the channel standard deviation, sample time to `sensor_sample_time`, and seed to the channel seed.
3. Add a first-order Transfer Fcn with numerator `1` and denominator `[tau 1]`.
4. Add a Gain with value `sensor_noise_enabled`.
5. Add a two-input Sum configured as `++`.
6. Connect the true state to the first sum input and the filtered, enabled noise to the second.
7. Send the sum output to the measured-state Outport.
8. At the model root, keep the scopes on true states and reconnect controller feedback inputs to measured states.

This is an introductory sensor model. Bias, drift, quantisation, axis misalignment, delay, dropouts, and an estimator can be added later without changing the controller interfaces.

## 2. Flight modes

`Flight_Mode_Manager` chooses references, while `Attitude_Mode_Selector` decides whether roll and pitch come from the pilot-style manual commands or the position-control path.

| `flight_mode` | Name | Horizontal control | Altitude and yaw references |
|---:|---|---|---|
| 1 | Stabilize / manual attitude | `phi_manual`, `theta_manual` go directly to the inner attitude loops | `z_manual`, `psi_manual` |
| 2 | Position Hold | x and y outer loops use `x_hold`, `y_hold` | `z_hold`, `psi_hold` |
| 3 | Auto waypoint | existing x/y Step commands | existing z/yaw Step commands |

The mode manager uses two cascaded Switch blocks for each x/y/z/yaw reference:

- a threshold of 2.5 chooses Auto for mode 3 and Hold otherwise;
- a threshold of 1.5 chooses the position-path result for modes 2 and 3 and the manual reference for mode 1.

For roll and pitch, a separate selector uses the 1.5 threshold. Mode 1 chooses the manual attitude constants. Modes 2 and 3 choose the yaw-aware position output.

### How to build it yourself

1. Put `flight_mode` in a Constant block so every selection uses the same mode value.
2. Bring the four automatic references into a subsystem through Inports.
3. Add manual and hold Constant blocks for x, y, z, and yaw.
4. Build the two-stage switch chain for each reference.
5. Expose x/y/z/yaw references, manual roll, manual pitch, and the mode as Outports.
6. Feed the x/y outputs to the position controllers, z to the altitude controller, and yaw to the yaw controller.
7. Add two final attitude Switch blocks to choose manual or position-generated roll and pitch.

The current model expects the mode to be chosen before a simulation. Switching modes while it is running is possible, but the controller integrators retain their previous states. A later refinement would add bumpless transfer, reset logic, and mode-transition conditions.

## 3. Yaw-aware position control

The x and y controllers were originally correct only when yaw was near zero. Their outputs can be interpreted as the pitch and roll commands that would produce the desired world-frame acceleration at zero yaw:

```text
theta_zero_yaw = command from the x controller
phi_zero_yaw   = command from the y controller
```

For small roll and pitch, the model's horizontal force equations reduce to

```text
ax proportional to  cos(psi)*theta + sin(psi)*phi
ay proportional to  sin(psi)*theta - cos(psi)*phi
```

Solving that pair for the body attitude commands gives

```text
theta_position = cos(psi)*theta_zero_yaw - sin(psi)*phi_zero_yaw
phi_position   = sin(psi)*theta_zero_yaw + cos(psi)*phi_zero_yaw
```

The subsystem calculates sine and cosine of measured yaw, forms the four products, combines them with `+-` and `++` Sum blocks, and applies the final `+/- tilt_max` limits. At zero yaw, cosine is 1 and sine is 0, so the mapping reduces exactly to the previous controller connection.

### Why the rotation matters

At 90 degrees yaw, the drone's body x and y axes are rotated relative to the world x and y axes. A world-x correction therefore cannot always be made with the same body-pitch command. The mapping rotates the world-oriented position-controller request into the body attitude axes before it reaches the roll and pitch controllers.

### How to build it yourself

1. Feed measured yaw to one Sin and one Cos block.
2. Multiply `cos(psi)` by `theta_zero_yaw`.
3. Multiply `sin(psi)` by `phi_zero_yaw` and subtract it from step 2.
4. Multiply `sin(psi)` by `theta_zero_yaw`.
5. Multiply `cos(psi)` by `phi_zero_yaw` and add it to step 4.
6. Saturate both final commands at `+/- tilt_max`.
7. Send the results to the flight-mode attitude selector.

## 4. Root-model layout and signal routing

The root diagram is arranged in two horizontal bands:

- command generation, flight-mode selection, controllers, mixer, and motors are across the top;
- disturbance generation, rigid-body dynamics, translation, and sensors are below.

Long connections use visible, globally scoped Goto/From tags. The tag names state both the signal type and meaning:

- `MEAS_*` for controller feedback;
- `TRUE_*` for plant states;
- `MOTOR_T*` and `MOTOR_OMEGA_SQ*` for motor outputs;
- `DIST_*` for forces and torques.

Each receiving tag is placed directly beside the destination port. This keeps the model readable without changing the numerical signal path.

## 5. Validation results

The saved validation records show that the final model passed structural checks, compiled successfully, and passed the eight configured behavioral cases listed below.

| Case | Command or target | Final result |
|---|---|---|
| Mode 3, zero yaw | x=4 m, y=2 m, z=1 m, yaw=0 deg | x=4.000000, y=2.000000, z=1.000000, yaw approximately 0 |
| Mode 3, yaw-aware | x=4 m, y=2 m, z=1 m, yaw=45 deg | x=4.000000, y=2.000000, z=1.000000, yaw=45.000000 deg |
| Mode 2, hold | x=1 m, y=-1 m, z=0.8 m, yaw=20 deg | x=1.000000, y=-1.000000, z=0.799991, yaw=20.000000 deg |
| Mode 1, manual attitude | roll=3 deg, pitch=-2 deg, z=0.8 m, yaw=10 deg | roll=3.000000 deg, pitch=-1.999638 deg, z=0.745203 m, yaw=10.000000 deg |
| Mode 3, noise enabled | x=4 m, y=2 m, z=1 m, yaw=0 deg | x=3.999649, y=2.000649, z=1.000686, yaw=0.014131 deg |
| Repeat noisy run | same seeds and settings | final-state difference exactly zero |
| Mode 3, disturbances enabled | all six configured pulses | x=4.000000, y=2.000000, z=1.000005, yaw approximately 0 deg |
| Combined system | yaw=30 deg, noise and all disturbances enabled | x=3.999092, y=1.999077, z=1.000746, yaw=30.023201 deg |

The manual-attitude case deliberately commands a constant tilt, so x and y drift rather than hold position. That is the expected behavior of Stabilize mode. The noise test remained below the 12.5 N motor limit, reaching 9.103592 N maximum thrust.

The combined case reached 10.513925 N maximum motor thrust, below the 12.5 N limit. The complete traces and numeric results are saved in `outputs/validation/guidance_sensor_validation.mat`. The repeatable validation procedure is in `tests/validate_guidance_features.m`, and `docs/SYSTEM_VALIDATION_REPORT.md` records the acceptance criteria and interpretation.
