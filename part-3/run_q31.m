function [L, P, mem] = run_q31(Tend)
% RUN_Q31  Builds and simulates the hybrid automaton H_f of Q3.1.
if nargin < 1, Tend = 112; end
P = params_printer();
Q = fr_modes();

H.ctrl      = @fr_ctrl;
H.guards    = @fr_guards;
H.on_guard  = @fr_on_guard;
H.on_sample = @fr_on_sample;
H.sampled   = @(q) any(q == [Q.STOP Q.MOVEV Q.MOVEH]);

% initial state: printing the ellipse, nozzle hot, spool almost finished
[r, rd, rdd, rddd] = ellipse_ref(0, P);
[~, ix0] = axis_ff(rd(1), rdd(1), rddd(1), P.Bfx, P);
[~, iy0] = axis_ff(rd(2), rdd(2), rddd(2), P.Bfy, P);
xi0 = [r(1) rd(1) ix0  r(2) rd(2) iy0  ...
       P.Thigh P.Un_hold P.Un_hold/P.Rn  P.Ls-0.002  0  0]';

mem.wall = [0 0];  mem.z = 0;  mem.s = r;  mem.C = zeros(2,6);
mem.tC = 60;  mem.Cdone = false;

L = hybrid_sim(H, xi0, Q.PRINT, mem, Tend, P);
end
