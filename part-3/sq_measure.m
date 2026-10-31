function [p, v, rot] = sq_measure(xi, mem, P)
% SQ_MEASURE  Everything the controller of Q3.2 knows about the head:
% it is computed ONLY from the motor angular sensors (encoder angles,
% relative to power-on, and angular velocities) and the CoreXY kinematics.
[wl, wr, thl, thr] = motor_sensors(xi, P);       % "true" motor angles
enc = [thl; thr] - mem.th0;                        % encoder counts since power-on
Pi  = 0.5*[1 1; 1 -1];
p   = P.rm*Pi*(enc - mem.thref);                   % meaningful after homing
v   = P.rm*Pi*[wl; wr];
rot = max(abs(wl), abs(wr)) > P.epsw;
end
