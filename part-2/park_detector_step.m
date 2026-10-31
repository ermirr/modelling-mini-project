function z = park_detector_step(z, M, m)
% PARK_DETECTOR_STEP  One transition of the head-parked detector A_p (Q2.2).
% Used by park_detector.m and by the hybrid models of Part 3.
%   z : current state, 0 = nothing known, 1 = bottom edge (y=0) known,
%       2 = left edge (x=0) known, 3 = parked in (0,0)  (accepting)
%   M : 1 = horizontal command H, 2 = vertical command V
%   m : 1 = motors rotating (+), 0 = motors not rotating (0)
%
% (H,+) destroys the knowledge of x, (V,+) the knowledge of y,
% (H,0) gives x = 0 and (V,0) gives y = 0. A pure H motion does not
% change y and a pure V motion does not change x (CoreXY kinematics).

%        (H,+) (H,0) (V,+) (V,0)
delta = [  0     2     0     1 ;   % q0
           1     3     0     1 ;   % q1  y = 0
           0     2     2     3 ;   % q2  x = 0
           1     3     2     3 ];  % q3  parked
col = 2*(M-1) + (2 - m);          % (H,+)->1 (H,0)->2 (V,+)->3 (V,0)->4
z = delta(z+1, col);
end
