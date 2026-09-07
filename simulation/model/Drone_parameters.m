%% Drone simulation parameters
% Nominal educational-model values. These have not been calibrated against
% a real airframe. SI units and radians are used inside the model.

%% Vehicle and environment
m = 2.6;                    % Nominal vehicle mass (kg)
g = 9.81;                   % Nominal gravity magnitude (m/s^2)
Ixx = 0.05;                 % Roll inertia (kg*m^2)
Iyy = 0.05;                 % Pitch inertia (kg*m^2)
Izz = 0.10;                 % Yaw inertia (kg*m^2)
d = 0.20;                   % Effective roll/pitch moment arm (m)

% Preserve the model's original rounded constants for exact reproducibility.
mg = 25.5;                  % Effective weight force used by model (N)
inv_m = 0.3846;             % Effective inverse mass used by model (1/kg)

%% Motor and propeller
kf = 4.0e-5;                % Thrust coefficient (N/(rad/s)^2)
km = 1.0e-6;                % Reaction-torque coefficient (N*m/(rad/s)^2)
tau_m = 0.05;               % Rotor-speed time constant (s)
Tmin = 0;                   % Minimum thrust command per motor (N)
Tmax = 12.5;                % Maximum thrust command per motor (N)
omega_init = 399;           % Initial rotor speed (rad/s), preserved value
omega_hover = sqrt((mg/4)/kf); % Hover speed implied by effective weight

%% Controller gains: current tuned values
Kp_z = 1.0;     Ki_z = 0;       Kd_z = 4.5;   N_z = 100;
Kp_phi = 1.0;   Ki_phi = 0;     Kd_phi = 0.5; N_phi = 100;
Kp_theta = 0.8; Ki_theta = 0.28; Kd_theta = 0.28; N_theta = 100;
Kp_psi = 1.0;   Ki_psi = 0;     Kd_psi = 0.5; N_psi = 100;
Kp_x = 0.1;     Ki_x = 0;       Kd_x = 0.16;  N_x = 100;
Kp_y = 0.1;     Ki_y = 0;       Kd_y = 0.16;  N_y = 100;

%% Control allocation and limits
pitch_pair_allocation = 1/(2*d); % Pair pitch correction (1/m)
roll_motor_allocation = 1/(4*d); % Per-motor roll correction (1/m)
yaw_motor_allocation = kf/(4*km); % Per-motor yaw correction
tilt_max = 0.1745;               % Outer-loop attitude limit (rad)

%% Command scenario
x_des = 4;                    % Desired x position (m)
y_des = 2;                    % Desired y position (m)
z_des = 1;                    % Desired altitude (m)
psi_des = deg2rad(0);         % Desired yaw angle (rad)
phi_des = deg2rad(0);         % Manual roll reference, currently unused (rad)
theta_des = deg2rad(10);      % Manual pitch reference, currently unused (rad)
t_step_xy = 1;                % X/Y command step time (s)
t_step_yaw = 1;               % Yaw command step time (s)
t_step_z = 0;                 % Altitude command step time (s)
t_stop = 100;                 % Simulation stop time (s)

%% Switchable disturbance demonstration
% 0 disables every disturbance and reproduces the nominal model. Set to 1
% to apply the six pulses sequentially.
disturbances_enabled = 0;
Fx_gust = 1.0;       t_Fx_start = 10; t_Fx_end = 11;       % N, s
Fy_gust = 1.0;       t_Fy_start = 15; t_Fy_end = 16;       % N, s
Fz_gust = 0.5;       t_Fz_start = 20; t_Fz_end = 21;       % N, s
tau_roll_gust = 0.01;  t_roll_start = 25;  t_roll_end = 25.5;   % N*m, s
tau_pitch_gust = 0.01; t_pitch_start = 30; t_pitch_end = 30.5;  % N*m, s
tau_yaw_gust = 0.002;  t_yaw_start = 35;   t_yaw_end = 35.5;    % N*m, s

%% Initial conditions
x0 = 0; y0 = 0; z0 = 0;      % Position (m)
vx0 = 0; vy0 = 0; vz0 = 0;   % Translational velocity (m/s)
phi0 = 0; theta0 = 0; psi0 = 0; % Attitude (rad)
phi_dot0 = 0; theta_dot0 = 0; psi_dot0 = 0; % Angular rate (rad/s)

%% Display conversion
rad_to_deg = 180/pi;

%% Basic sensor model
sensor_noise_enabled = 0;       % 0 = true states, 1 = add seeded noise
sensor_sample_time = 0.02;      % Sensor update period (s)
sensor_noise_tau_position = 0.20; % Position-noise shaping time constant (s)
sensor_noise_tau_attitude = 0.10; % Attitude-noise shaping time constant (s)
sigma_x = 0.002; sigma_y = 0.002; % Horizontal position noise (m)
sigma_z = 0.001;                  % Altitude measurement noise (m)
sigma_phi = deg2rad(0.02);        % Roll measurement noise (rad)
sigma_theta = deg2rad(0.02);      % Pitch measurement noise (rad)
sigma_psi = deg2rad(0.05);        % Yaw measurement noise (rad)
seed_x = 101; seed_y = 102; seed_z = 103;
seed_phi = 104; seed_theta = 105; seed_psi = 106;

%% Flight modes and references
% 1 = Stabilize/manual attitude, 2 = Position Hold, 3 = Auto waypoint
flight_mode = 3;
x_manual = 0; y_manual = 0; z_manual = 1; psi_manual = 0;
phi_manual = 0; theta_manual = 0;
x_hold = 0; y_hold = 0; z_hold = 1; psi_hold = 0;

%% 3-D visualization
visual_frame_rate = 30;          % Display frames per second
visual_playback_speed = 4;       % Simulated seconds per real second
visual_arm_length = 0.35;        % Display-only arm length (m)
visual_trail_length = inf;       % Keep the complete trajectory visible
visual_demo_stop_time = 60;      % Demonstration duration (s)
visual_demo_yaw = deg2rad(30);   % Demonstration yaw command (rad)
visual_demo_disturbances = 1;    % Include the configured disturbance pulses
visual_demo_sensor_noise = 0;    % Use ideal state feedback for a clear first view
visual_record_video = 0;         % Set to 1 to also save an MP4 video
