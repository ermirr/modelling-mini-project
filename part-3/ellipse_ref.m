function [r, rd, rdd, rddd] = ellipse_ref(tp, P)
% ELLIPSE_REF  Ellipse of Q1.4 (semi-axes 80 and 50 mm, omega = 0.5 rad/s)
% and its first three time derivatives, as a function of the clock tp.
w = 0.5;  a = 0.08;  b = 0.05;
c = w*tp;
r    = [P.dx/2 + a*cos(c);  P.dy/2 + b*sin(c)];
rd   = [-a*w*sin(c);         b*w*cos(c)];
rdd  = [-a*w^2*cos(c);      -b*w^2*sin(c)];
rddd = [ a*w^3*sin(c);      -b*w^3*cos(c)];
end