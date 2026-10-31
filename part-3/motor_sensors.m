function [wl, wr, thl, thr] = motor_sensors(xi, P)
% MOTOR_SENSORS  Angular velocities and angles of the two motors,
% from the inverse CoreXY kinematics of Q1.1 (theta = 0 at (0,0)).
wl  = (xi(2) + xi(5))/P.rm;
wr  = (xi(2) - xi(5))/P.rm;
thl = (xi(1) + xi(4))/P.rm;
thr = (xi(1) - xi(4))/P.rm;
end
