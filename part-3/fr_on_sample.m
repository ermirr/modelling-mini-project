function [q, xi, mem] = fr_on_sample(t, q, xi, mem, P)
% FR_ON_SAMPLE  Guards of H_f evaluated by the supervisor every Ts:
%   C (external input), S (motors stopped), detector A_p of Q2.2.
Q = fr_modes();
[wl, wr] = motor_sensors(xi, P);
rot = max(abs(wl), abs(wr)) > P.epsw;          % m_k = + (1) or 0 (0)

% a C arriving during the replacement is ignored (as in Q2.1)
if ~mem.Cdone && t >= mem.tC, mem.Cdone = true; end

switch q
    case Q.STOP
        if ~rot                                    % S
            q = Q.MOVEV;  mem.z = 0;               % detector reset
        end
    case Q.MOVEV
        mem.z = park_detector_step(mem.z, 2, rot); % sample (V, m_k)
        if ~rot, q = Q.MOVEH; end                  % P_V: sample (V,0)
    case Q.MOVEH
        mem.z = park_detector_step(mem.z, 1, rot); % sample (H, m_k)
        if mem.z == 3                              % A_p accepts: parked
            q = Q.WIPE;  xi(11) = 0;
        end
end
end
