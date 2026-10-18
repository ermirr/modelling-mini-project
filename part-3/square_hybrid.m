function sim = square_hybrid(P, sq)
% SQUARE_HYBRID  Simulation of the hybrid automaton that draws a square (Q3.2).
%
%   sim = square_hybrid(P, sq)
%
%   P  : model of the motors, from printer_model()
%   sq : struct with the square to draw
%        sq.c0         first corner [m] (2x1), the head starts here at rest
%        sq.a          side length [m]
%        sq.U          constant axis voltage used on each side [V]
%        sq.epsw       tolerance for "motors stopped" (event S) [rad/s]
%        sq.brakeAhead true:  brake in advance by the braking distance d_b
%                      false: brake when the corner is reached
%
%   Modes (8 + end): D1 B1 D2 B2 D3 B3 D4 B4 -> End
%     D_k : draw side k with constant voltage U along the direction n_k
%     B_k : corner k, u_m = 0 (braking as in q1 of Q3.1)
%   Guards use only the angular motion sensors (theta_l, theta_r, omega_l,
%   omega_r), through the CoreXY kinematics p = p0 + rm*Pi*theta:
%     D_k -> B_k : n_k'*(c_k - p(theta)) <= d_b(k)        (corner reached)
%     B_k -> D_k+1 : |omega_l| <= epsw and |omega_r| <= epsw  (event S)
%
%   sim.t, sim.eta, sim.mode, sim.um : time, state, mode, motor voltages
%   sim.p                            : head position computed from theta
%   sim.corners, sim.db, sim.tSwitch : corners, braking distances, switch times

n = [1 0; 0 1; -1 0; 0 -1]';                 % directions of sides 1..4
c = sq.c0 + sq.a*cumsum(n, 2);               % corners c_1..c_4 (c_4 = c_0)

% braking distance d_b along each side, computed with the model:
% steady state z_ss = (omega, i) under constant voltage, then with u_m = 0
% z' = Ar z  ->  integral of omega = -Ar^-1 z_ss
Ar = P.A(3:6, 3:6);  Br = P.B(3:6, :);
db = zeros(1, 4);
if sq.brakeAhead
    for k = 1:4
        zss   = -Ar \ (Br*(P.Pi*(sq.U*n(:,k))));
        dth   = -[eye(2) zeros(2)] * (Ar \ zss);
        db(k) = n(:,k)' * (P.rm*P.Pi*dth);
    end
end

theta0 = (2/P.rm)*P.Pi*(sq.c0 - P.p0);       % inverse kinematics, Pi^-1 = 2*Pi
eta0   = [theta0; 0; 0; 0; 0];
opts0  = odeset('RelTol', 1e-8, 'AbsTol', 1e-10);

sim.t = []; sim.eta = []; sim.mode = []; sim.um = [];
sim.tSwitch = 0;
t0 = 0;
for q = 1:8
    k = ceil(q/2);                           % side / corner index
    if mod(q, 2) == 1                        % D_k : draw side k
        um  = P.Pi*(sq.U*n(:,k));
        evf = @(t, eta) evDraw(eta, P, n(:,k), c(:,k), db(k));
        tmax = 10*sq.a/(sq.U/600);           % safety limit on the duration
    else                                     % B_k : brake at corner k
        um  = [0; 0];
        evf = @(t, eta) evStop(eta, sq.epsw);
        tmax = 1;
    end
    opts = odeset(opts0, 'Events', evf);
    [t, eta] = ode45(@(t, eta) P.A*eta + P.B*um, [t0, t0 + tmax], eta0, opts);
    sim.t    = [sim.t; t];
    sim.eta  = [sim.eta; eta];
    sim.mode = [sim.mode; q*ones(numel(t), 1)];
    sim.um   = [sim.um; repmat(um', numel(t), 1)];
    t0   = t(end);
    eta0 = eta(end, :)';                     % identity reset
    sim.tSwitch(end+1) = t0;
end
sim.p       = (P.p0 + P.rm*P.Pi*sim.eta(:, 1:2)')';
sim.corners = [sq.c0, c];
sim.db      = db;
end

function [value, isterminal, direction] = evDraw(eta, P, nk, ck, dbk)
% guard D_k -> B_k, from the angles only
p = P.p0 + P.rm*P.Pi*eta(1:2);
value = nk'*(ck - p) - dbk;
isterminal = 1;
direction  = -1;
end

function [value, isterminal, direction] = evStop(eta, epsw)
% guard B_k -> D_k+1 (event S), from the angular velocities only
value = max(abs(eta(3:4))) - epsw;
isterminal = 1;
direction  = -1;
end
