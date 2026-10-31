function [val, dir] = fr_guards(t, q, xi, mem, P)
% FR_GUARDS  Guards of H_f that depend on the continuous state.
%   val crosses zero (in direction dir) exactly when the guard becomes true.
Q = fr_modes();
switch q
    case Q.PRINT                                       % F : ell >= Ls
        % C is an external input, read by the supervisor at the first
        % sampling instant after t_C: written as a time guard
        tCs = ceil(mem.tC/P.Ts - 1e-9)*P.Ts;
        if mem.Cdone, gC = 1; else, gC = t - tCs; end
        val = [xi(10) - P.Ls; gC];  dir = [+1; +1];
    case Q.WIPE,   val = xi(11) - P.Tw;   dir = +1;   % W : tau >= Tw
    case Q.HOFF,   val = xi(7) - P.Tlow;  dir = -1;   % T_L: Tn <= Tlow
    case Q.LOAD,   val = xi(11) - P.Tld;  dir = +1;   % L : tau >= Tld
    case Q.HON,    val = xi(7) - P.Thigh; dir = +1;   % T_H: Tn >= Thigh
    case Q.RESUME, val = xi(11) - P.Tm;   dir = +1;   % M : tau >= Tm
    otherwise,     val = 1;               dir = 0;    % sampled guards only
end
end
