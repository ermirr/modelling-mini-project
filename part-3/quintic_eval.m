function [r, rd, rdd, rddd] = quintic_eval(C, tau)
% QUINTIC_EVAL  Evaluates the quintic of QUINTIC_COEFFS (2x1 outputs).
t = tau;
r    = C*[1; t; t^2; t^3; t^4; t^5];
rd   = C*[0; 1; 2*t; 3*t^2; 4*t^3; 5*t^4];
rdd  = C*[0; 0; 2; 6*t; 12*t^2; 20*t^3];
rddd = C*[0; 0; 0; 6; 24*t; 60*t^2];
end
