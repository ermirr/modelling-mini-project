function [q, xi, mem] = fr_on_guard(k, t, q, xi, mem, P)
% FR_ON_GUARD  Edges of H_f taken on a continuous guard, with resets.
Q = fr_modes();
switch q
    case Q.PRINT
        mem.s = [xi(1); xi(4)];  q = Q.STOP;  % reset s+ = p
        if k == 2, mem.Cdone = true; end      % guard 2 = C (new colour)
    case Q.WIPE                         % W
        q = Q.HOFF;
    case Q.HOFF                         % T_L
        xi(11) = 0;  q = Q.LOAD;
    case Q.LOAD                         % L: new spool
        xi(10) = 0;  q = Q.HON;
    case Q.HON                          % T_H
        xi(11) = 0;  q = Q.RESUME;
        % trajectory from the wipe tower to s, arriving with the velocity
        % and acceleration of the ellipse at the saved printing time tp
        [~, rd, rdd] = ellipse_ref(xi(12), P);
        [rs] = ellipse_ref(xi(12), P);
        mem.C = quintic_coeffs([xi(1); xi(4)], [0;0], [0;0], rs, rd, rdd, P.Tm);
    case Q.RESUME                       % M
        q = Q.PRINT;
end
end
