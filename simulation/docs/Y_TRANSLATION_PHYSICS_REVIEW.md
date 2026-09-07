# Y translation physics review

The model uses ZYX roll-pitch-yaw kinematics. The inertial y component of the body-z thrust direction is:

`Fy/T = sin(psi)*sin(theta)*cos(phi) - cos(psi)*sin(phi)`

Before this review the model used:

`Fy/T = sin(psi)*sin(theta)*cos(psi) - cos(phi)*sin(phi)`

That version is close for small roll with zero yaw, explaining the successful original plots, but it is not correct in general. Across phi, theta and psi in {-20,-10,0,10,20} degrees, the maximum normalized force error was 0.020626338. At 25.5 N thrust and inverse mass 0.3846, this corresponds to 0.20228869 m/s^2 maximum acceleration error.

The two input connections were corrected and the affected product blocks renamed. X translation already matched the same ZYX convention.

## Closed-loop validation

A 30-second scenario commanded x = 4 m, y = 2 m, z = 1 m and yaw = 30 degrees. Before correction it ended at [x y z psi] = [4.0000052, 2.0000012, 0.99935713, 0.52359895]. After correction it ended at [4.0000053, 2.0000013, 0.99934345, 0.52359898]. Both runs converged, explaining why the original outputs appeared fine. The corrected version now agrees with the rotation matrix at intermediate attitudes as well as at the endpoint.

## Parameterization validation

After replacing numeric block values with model-workspace variables, the same nonzero-yaw scenario was rerun. The maximum absolute difference after interpolation across all 28 continuous states was 6.00715737e-07 (maximum scaled difference 1.81014309e-09). This is solver sampling variation at the configured relative tolerance; final coordinates agree to the printed precision.
