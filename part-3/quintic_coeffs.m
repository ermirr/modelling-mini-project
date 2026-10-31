function C = quintic_coeffs(p0, v0, a0, p1, v1, a1, T)
% QUINTIC_COEFFS  Coefficients (2x6, ascending powers of tau) of the
% quintic r(tau) with given position, velocity and acceleration at
% tau = 0 and tau = T, one row per axis.
M = [1 0 0    0      0       0;
     0 1 0    0      0       0;
     0 0 2    0      0       0;
     1 T T^2  T^3    T^4     T^5;
     0 1 2*T  3*T^2  4*T^3   5*T^4;
     0 0 2    6*T    12*T^2  20*T^3];
C = zeros(2,6);
for k = 1:2
    C(k,:) = (M \ [p0(k); v0(k); a0(k); p1(k); v1(k); a1(k)]).';
end
end
