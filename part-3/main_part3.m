% MAIN_PART3  Part 3: hybrid systems.
clear; clc; close all;
if ~exist('figures', 'dir'), mkdir('figures'); end

%% Q3.1 - Filament replacement
% Printing the ellipse of Q1.4 with an almost empty spool: the spool
% finishes (event F), the filament is replaced and printing resumes;
% at t_C = 60 s a new colour is required (event C).
[L, P] = run_q31(112);
fprintf('Q3.1\n   time [s]   event\n');
for k = 1:size(L.events,1)
    fprintf('%10.4f   %s\n', L.events{k,1}, L.events{k,2});
end
Q = fr_modes();                 % contour error while printing
e = zeros(size(L.t));
for j = find(L.q == Q.PRINT)'
    r = ellipse_ref(L.xi(j,12), P);
    e(j) = norm([L.xi(j,1); L.xi(j,4)] - r);
end
fprintf('max contour error while printing: %.3g mm\n', 1e3*max(e));
plot_q31(L, P, 'figures');


%% Q3.2 - Draw a square
% The head starts at rest in an unknown position; it is parked in (0,0)
% with the procedure and the detector of Q2.2 (homing), the encoder
% reference is reset there, then the four sides are drawn one at a time.
[L, P] = run_q32(30);
S = sq_modes();
fprintf('\nQ3.2\n   time [s]   event\n');
for k = 1:size(L.events,1)
    fprintf('%10.4f   %s\n', L.events{k,1}, L.events{k,2});
end
sq.corners = [0.05 0.15 0.15 0.05; 0.05 0.05 0.15 0.15];   % as in run_q32
X = L.xi;  q = L.q;
dev = zeros(1,4);  len = zeros(1,4);      % straightness and length of each side
for s = 1:4
    k = (q == S.SIDE1 + s - 1);
    if mod(s,2) == 1, dev(s) = max(abs(X(k,4) - sq.corners(2,s)));   % horizontal side
    else,             dev(s) = max(abs(X(k,1) - sq.corners(1,s)));   % vertical side
    end
    i0 = find(k, 1);  i1 = find(k, 1, 'last');
    len(s) = norm([X(i1,1)-X(i0,1); X(i1,4)-X(i0,4)]);
end
fprintf('side lengths [mm]       : %s\n', mat2str(1e3*len, 6));
fprintf('max deviation from side : %s um\n', mat2str(1e6*dev, 3));
plot_q32(L, P, sq, 'figures');