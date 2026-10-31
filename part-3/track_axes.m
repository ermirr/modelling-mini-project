function uxy = track_axes(rd, rdd, rddd, P)
% TRACK_AXES  Feed-forward of Q1.4 on the two axes (no feedback).
ux = axis_ff(rd(1), rdd(1), rddd(1), P.Bfx, P);
uy = axis_ff(rd(2), rdd(2), rddd(2), P.Bfy, P);
uxy = [ux; uy];
end