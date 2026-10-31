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