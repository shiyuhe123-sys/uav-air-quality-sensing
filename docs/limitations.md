# Current limitations

- One physical flight on 28 September 2026 has been analysed; repeated-flight and final-payload performance are not established.
- The final sensor mount/inlet, all-up payload mass and centre of gravity remain pending. The approximately 3 kg flight mass is builder-reported.
- No air-quality dataset, sensor calibration, rotor-flow bias comparison, repeatability result or spatial map exists.
- Installed-propeller current, thermal behaviour and endurance have not been established as repeatable performance results.
- Exact as-built ports, cable pinout and exported parameters are not included in the public hardware record.
- The featured model comparison is conditional same-flight RTL target tracking, initialized once from logged state and using recorded internal targets.
- The eight-component project score is 7.363/10, below the original 8/10 target. Small altitude error does not establish a general aircraft model.
- Prior parameter selection and inspection mean the comparison is not untouched independent validation.
- CTUN/EKF and GPS are logged estimator references with different sampling rates and coordinate conventions.
- Mass, propulsion capacity, inertia, actuator response, damping and effective axis alignment are not comprehensively identified.
- The manual-descent event remains unexplained; whole-flight, Stabilize/Loiter transfer and new-flight prediction remain unresolved.
- Firmware integrator management, estimator realism, ground contact, spool-up and crash dynamics are outside the supported model scope.
- The Simulink controller is separate from the aircraft's ArduCopter controller and has not been deployed to the Pixhawk.
- Public derived local-coordinate evidence supports rerunning the RTL comparison. Full raw-log processing and diagnostic provenance require the private source evidence.
