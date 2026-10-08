function converted = ardupilot_to_model_attitude(angles)
%ARDUPILOT_TO_MODEL_ATTITUDE NED/FRD Euler angles to the model's Up-axis convention.
% R_model = S*R_ArduPilot*S, S=diag([1 1 -1]). The mapping is self-inverse.
arguments
    angles (:,3) double {mustBeFinite}
end
converted=angles.*[-1,-1,1];
end
