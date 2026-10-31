function u = sq_ctrl(t, q, xi, mem, P)
% SQ_CTRL  Inputs of the square-drawing automaton: u = [ux uy un e tpdot]'.
S = sq_modes();
[~, v] = sq_measure(xi, mem, P);
uxy = [0; 0];  e = 0;
switch q
    case S.HOMEV
        uxy = [0; -P.Up];                         % command V (down)
    case S.HOMEH
        uxy = [-P.Up; 0];                         % command H (left)
    case {S.GOTO, S.SIDE1, S.SIDE2, S.SIDE3, S.SIDE4}
        tau = min(xi(11), mem.Tseg);
        [~, rd, rdd, rddd] = quintic_eval(mem.C, tau);
        uxy = track_axes(rd, rdd, rddd, P);
        if q ~= S.GOTO, e = P.alpha*norm(v); end % extrude on the sides
    case S.DONE
        % square finished, the head stays at rest in A (u = 0)
end
u = [uxy; P.Un_hold; e; 0];
end