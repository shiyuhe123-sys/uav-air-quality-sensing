# Drone model parameters

`model/Drone_parameters.m` is the single parameter source for `model/Drone_simulation.slx`. It is linked directly to the Simulink **Model Workspace** as a MATLAB-file data source. This avoids competing copies of the same values in the base and model workspaces.

Edit the script to change:

- vehicle mass, gravity, inertias and effective arm;
- motor coefficients, time constant, thrust limits and initial rotor speed;
- six controller PID gains and derivative-filter coefficients;
- mixer allocation coefficients and outer-loop tilt limit;
- x/y/z/yaw automatic commands and their step times;
- flight mode plus manual-attitude and position-hold references;
- sensor noise levels, sample time, shaping time constants and random seeds;
- six switchable disturbance magnitudes and pulse times;
- 3-D display size, playback, demonstration, trail and recording settings;
- position, velocity, attitude and angular-rate initial conditions;
- simulation stop time.

The model's historical values `mg = 25.5` N and `inv_m = 0.3846` 1/kg are retained explicitly. They differ slightly from `m*g = 25.506` N and `1/m = 0.384615...` 1/kg. This keeps the existing tuning and outputs reproducible. Replacing them with derived expressions should be treated as a separate numerical change.

When the model is first opened, Simulink initializes its model workspace from `Drone_parameters.m`. After editing the parameter file while the model remains open, run `reload_drone_parameters.m` once before simulating. SimulationInput overrides must specify `Workspace='Drone_simulation'` because the parameters belong to the model workspace.

Set `flight_mode` to 1 for Stabilize/manual attitude, 2 for Position Hold, or 3 for the automatic Step-command scenario. The saved default is mode 3. Manual roll and pitch use `phi_manual` and `theta_manual`; the older `phi_des` and `theta_des` values are retained only as legacy reference values and are not wired into the current command path.

Set `sensor_noise_enabled` to 1 to add deterministic, band-limited measurement noise. The six `sigma_*` values are standard deviations, and the six `seed_*` values make repeated simulations reproducible. Set `disturbances_enabled` independently to 1 to run the force and torque pulse sequence.
