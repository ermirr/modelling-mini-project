function [L, P, mem] = run_q32(Tend)
% RUN_Q32  Square drawn with the angular motion sensors only (Q3.2).
if nargin < 1, Tend = 30; end
P = params_printer();
P.Tside = 4;  P.Tgo = 4;              % [s] duration of one side / of the approach
S = sq_modes();
H.ctrl = @sq_ctrl;  H.guards = @sq_guards;  H.on_guard = @sq_on_guard;
H.on_sample = @sq_on_sample;  H.sampled = @(q) true;

a = 0.10;  A = [0.05; 0.05];            % side and first corner [m]
mem.corners = [A, A+[a;0], A+[a;a], A+[0;a]];
% the head is at rest in an unknown position; the encoders read 0 there
p_init = [0.12; 0.09];
mem.th0   = [(p_init(1)+p_init(2)); (p_init(1)-p_init(2))]/P.rm;  % unknown to the controller
mem.thref = [0; 0];  mem.z = 0;  mem.wall = [0 0];
mem.C = zeros(2,6);  mem.target = [0;0];  mem.Tseg = 1;

xi0 = [p_init(1) 0 0 p_init(2) 0 0  P.Thigh P.Un_hold P.Un_hold/P.Rn  0 0 0]';
L = hybrid_sim(H, xi0, S.HOMEV, mem, Tend, P);
end
