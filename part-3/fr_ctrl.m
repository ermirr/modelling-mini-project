function u = fr_ctrl(t, q, xi, mem, P)
% FR_CTRL  Mode-dependent inputs of H_f: u = [ux uy un e tpdot]'.
Q = fr_modes();
v = [xi(2); xi(5)];                     % from the motor encoders
uxy = [0; 0];  un = P.Un_hold;  e = 0;  tpd = 0;
switch q
    case Q.PRINT
        [~, rd, rdd, rddd] = ellipse_ref(xi(12), P);
        uxy = track_axes(rd, rdd, rddd, P);
        e = P.alpha*norm(v);  tpd = 1;
    case Q.STOP
        % u = 0: back-emf and friction stop the motors
    case Q.MOVEV
        uxy = [0; -P.Up];               % command V (downwards)
    case Q.MOVEH
        uxy = [-P.Up; 0];               % command H (to the left)
    case Q.WIPE
        e = P.vw;
    case Q.HOFF
        un = 0;
    case Q.LOAD
        un = 0;
    case Q.HON
        un = P.Un_max;
    case Q.RESUME
        tau = min(xi(11), P.Tm);
        [~, rd, rdd, rddd] = quintic_eval(mem.C, tau);
        uxy = track_axes(rd, rdd, rddd, P);
end
u = [uxy; un; e; tpd];
end
