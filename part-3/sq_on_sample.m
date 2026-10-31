function [q, xi, mem] = sq_on_sample(t, q, xi, mem, P)
% SQ_ON_SAMPLE  Sampled guards and resets of the square automaton (Q3.2).
S = sq_modes();
[p, ~, rot] = sq_measure(xi, mem, P);
switch q
    case S.HOMEV
        mem.z = park_detector_step(mem.z, 2, rot);   % sample (V, m_k)
        if ~rot, q = S.HOMEH; end                     % (V,0): bottom edge
    case S.HOMEH
        mem.z = park_detector_step(mem.z, 1, rot);   % sample (H, m_k)
        if mem.z == 3                                 % A_p accepts: (0,0)
            % reset of the encoder reference: here the head is in (0,0)
            [~, ~, thl, thr] = motor_sensors(xi, P);
            mem.thref = [thl; thr] - mem.th0;
            [p] = sq_measure(xi, mem, P);
            mem = new_segment(mem, p, mem.corners(:,1), P.Tgo);
            xi(11) = 0;  q = S.GOTO;
        end
    case {S.GOTO, S.SIDE1, S.SIDE2, S.SIDE3, S.SIDE4}
        arrived = xi(11) >= mem.Tseg && norm(p - mem.target) <= P.epsp && ~rot;
        if arrived
            if q == S.SIDE4
                q = S.DONE;
            else
                k = q - S.GOTO + 1;                   % side to draw next
                mem = new_segment(mem, mem.target, mem.corners(:, mod(k,4)+1), P.Tside);
                xi(11) = 0;  q = q + 1;
            end
        end
end
end

function mem = new_segment(mem, p0, p1, T)
% rest-to-rest quintic from p0 to p1 in time T
mem.C = quintic_coeffs(p0, [0;0], [0;0], p1, [0;0], [0;0], T);
mem.target = p1;  mem.Tseg = T;
end
