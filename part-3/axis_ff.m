function [u, i] = axis_ff(rd, rdd, rddd, Bf, P)
% AXIS_FF  Feed-forward voltage of one axis (inverse model of Q1.3/Q1.4)
% for a reference with velocity rd, acceleration rdd and jerk rddd.
i  = 2/(P.rm*P.Km)*(P.Jeq*rdd  + Bf*rd);
di = 2/(P.rm*P.Km)*(P.Jeq*rddd + Bf*rdd);
u  = P.Lm*di + P.Rm*i + 2*P.Km/P.rm*rd;
end
