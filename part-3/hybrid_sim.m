function L = hybrid_sim(H, xi0, q0, mem0, Tend, P)
% HYBRID_SIM  Simulation of a hybrid automaton built on PLANT_FLOW.
%
%   H.ctrl(t,q,xi,mem,P)            -> u = [ux uy un e tpdot]'  (flow of mode q)
%   H.guards(t,q,xi,mem,P)          -> [val, dir]  continuous guards of mode q
%   H.on_guard(k,t,q,xi,mem,P)      -> [q,xi,mem]  edge + reset for guard k
%   H.on_sample(t,q,xi,mem,P)       -> [q,xi,mem]  guards checked by the
%                                      supervisor every P.Ts (sensor logic)
%   H.sampled(q)                    -> true if mode q has sampled guards
%                                      (in the other modes the samples have
%                                      no effect and are skipped for speed)
%
% Physical events (head against the frame) are handled here: when the head
% reaches a wall the velocity of that axis is reset to zero (inelastic
% impact) and the axis stays blocked until the motor current pushes it away.
% Mode guards that depend on the continuous state are detected by the ODE
% solver (event functions); guards that depend on sampled sensor signals
% are evaluated at the sampling instants k*Ts.

opts = odeset('RelTol', 1e-7, 'AbsTol', 1e-9, 'Refine', 1);
t = 0;  xi = xi0(:);  q = q0;  mem = mem0;
if ~isfield(mem, 'wall'), mem.wall = [0 0]; end

% preallocated log
N = ceil(Tend/P.Ts)*12 + 1000;
L.t = zeros(N,1); L.xi = zeros(N,12); L.q = zeros(N,1); L.u = zeros(N,5);
L.wall = zeros(N,2); L.z = zeros(N,1);
n = 1;
L.t(1) = 0; L.xi(1,:) = xi'; L.q(1) = q; L.u(1,:) = H.ctrl(0,q,xi,mem,P)';
L.wall(1,:) = mem.wall; L.z(1) = getz(mem);
L.events = {};

stall = 0;  tLast = -1;
while t < Tend - 1e-12
    if H.sampled(q)
        tNext = (floor(t/P.Ts + 1e-9) + 1)*P.Ts;   % next sampling instant
    else
        tNext = Inf;
    end
    tStop = min(tNext, Tend);
    % release from the frame if the motor already pushes away from it
    for a = 1:2
        ia = 3*a;
        if (mem.wall(a) == -1 && xi(ia) >= P.irel) || ...
           (mem.wall(a) == +1 && xi(ia) <= -P.irel)
            mem.wall(a) = 0;  L.events(end+1,:) = {t, sprintf('release axis %d', a)};
        end
    end
    if tStop - t > 1e-12
        f  = @(tt,y) plant_flow(y, H.ctrl(tt,q,y,mem,P), mem.wall, P);
        ev = @(tt,y) all_events(tt, y, q, mem, P, H);
        [T, Y, te, ye, ie] = ode45(f, [t tStop], xi, odeset(opts, 'Events', ev));
        if ~isempty(ie)
            % keep only the solution up to the first event (some solver
            % versions do not stop on an event found in the first step)
            [te1, j1] = min(te);
            keep = T < te1;
            T = [T(keep); te1];  Y = [Y(keep,:); ye(j1,:)];
            ie = ie(j1);
            if te1 >= tStop - 1e-12, T(end) = tStop; end
        end
        % log
        k = numel(T) - 1;
        if n + k > numel(L.t), L = grow(L); end
        idx = n+1:n+k;
        L.t(idx) = T(2:end);  L.xi(idx,:) = Y(2:end,:);  L.q(idx) = q;
        for j = 2:numel(T)
            L.u(n+j-1,:) = H.ctrl(T(j),q,Y(j,:)',mem,P)';
        end
        L.wall(idx,:) = repmat(mem.wall, k, 1);  L.z(idx) = getz(mem);
        n = n + k;
        xi = Y(end,:)';  t = T(end);
    else
        ie = [];
    end

    if ~isempty(ie)
        % event (physical contact or mode guard): edge + reset
        [q, xi, mem, name] = handle_event(ie, t, q, xi, mem, P, H);
        L.events(end+1,:) = {t, name};
        if t == tLast, stall = stall + 1; else, stall = 0; end
        if stall > 50, error('hybrid_sim: too many events at t = %g', t); end
    end
    tLast = t;
    if abs(t - tNext) < 1e-12 && H.sampled(q)
        % sampling instant: guards evaluated by the supervisor
        q_old = q;
        [q, xi, mem] = H.on_sample(t, q, xi, mem, P);
        if q ~= q_old, L.events(end+1,:) = {t, sprintf('sample: %d -> %d', q_old, q)}; end
    end
end
L.t = L.t(1:n); L.xi = L.xi(1:n,:); L.q = L.q(1:n); L.u = L.u(1:n,:);
L.wall = L.wall(1:n,:); L.z = L.z(1:n);
end

% -------------------------------------------------------------------------
function [val, term, dir] = all_events(t, y, q, mem, P, H)
pos = [y(1) y(4)];  cur = [y(3) y(6)];  dmax = [P.dx P.dy];
val = zeros(4,1);  dir = zeros(4,1);
for a = 1:2
    j = 2*a - 1;
    switch mem.wall(a)
        case 0                      % free: lower and upper wall
            val(j)   = pos(a);          dir(j)   = -1;
            val(j+1) = pos(a) - dmax(a); dir(j+1) = +1;
        case -1                     % at lower wall: released if pushed up
            val(j)   = cur(a) - P.irel; dir(j)   = +1;
            val(j+1) = 1;               dir(j+1) = 0;
        case +1                     % at upper wall: released if pushed down
            val(j)   = cur(a) + P.irel; dir(j)   = -1;
            val(j+1) = 1;               dir(j+1) = 0;
    end
end
[gv, gd] = H.guards(t, q, y, mem, P);
val  = [val; gv(:)];
dir  = [dir; gd(:)];
term = ones(size(val));
end

function [q, xi, mem, name] = handle_event(k, t, q, xi, mem, P, H)
if k <= 4
    a = ceil(k/2);  upper = (mod(k,2) == 0);
    ip = 3*a - 2;   iv = 3*a - 1;          % indices of position/velocity
    dmax = [P.dx P.dy];
    if mem.wall(a) == 0
        mem.wall(a) = -1 + 2*upper;
        xi(ip) = upper*dmax(a);  xi(iv) = 0;   % inelastic impact
        name = sprintf('contact axis %d', a);
    else
        mem.wall(a) = 0;
        name = sprintf('release axis %d', a);
    end
else
    [q, xi, mem] = H.on_guard(k-4, t, q, xi, mem, P);
    name = sprintf('guard -> mode %d', q);
end
end

function z = getz(mem)
if isfield(mem, 'z'), z = mem.z; else z = NaN; end
end

function L = grow(L)
m = numel(L.t);
L.t(2*m) = 0; L.xi(2*m,12) = 0; L.q(2*m) = 0; L.u(2*m,5) = 0;
L.wall(2*m,2) = 0; L.z(2*m) = 0;
end
