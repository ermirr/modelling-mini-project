function plot_q32(L, P, mem, outdir)
% PLOT_Q32  Figures of the square-drawing simulation (Q3.2).
if nargin < 4, outdir = '.'; end
if ~isfolder(outdir), mkdir(outdir); end
S = sq_modes();
t = L.t;  X = L.xi;  q = L.q;
wl = (X(:,2) + X(:,5))/P.rm;   wr = (X(:,2) - X(:,5))/P.rm;
xx = 1e3*X(:,1);  yy = 1e3*X(:,4);
sd = q >= S.SIDE1 & q <= S.SIDE4;
c = 1e3*mem.corners;

f = figure('visible','off','position',[0 0 1000 640]);
subplot(2,2,1);
plot(xx(~sd), yy(~sd), '.', 'color', [0.6 0.6 0.6], 'markersize', 2); hold on;
plot(xx(sd), yy(sd), 'b.', 'markersize', 3);
plot(c(1,[1:4 1]), c(2,[1:4 1]), 'r--');
plot(1e3*0.12, 1e3*0.09, 'ko', 'markerfacecolor', 'k');
axis equal; grid on; xlim([-10 1e3*P.dx+10]); ylim([-10 1e3*P.dy+10]);
xlabel('x [mm]'); ylabel('y [mm]');
title('Path (\bullet start, grey: homing + approach, blue: printed, red: ideal)');

subplot(2,2,2);                         % zoom on corner B
k = sd & abs(xx - c(1,2)) < 0.02 & abs(yy - c(2,2)) < 0.02;
plot(1e3*(xx(k) - c(1,2)), 1e3*(yy(k) - c(2,2)), 'b.', 'markersize', 4); hold on;
plot([-20 0 0], [0 0 20], 'r--');
axis equal; grid on; xlim([-20 5]); ylim([-5 20]);
xlabel('x - x_B [\mum]'); ylabel('y - y_B [\mum]'); title('Zoom on corner B (\mum)');

subplot(2,2,3);
plot(t, xx, 'b', t, yy, 'r', 'linewidth', 1.2); grid on; hold on;
yl = [-10 170]; ylim(yl);
for j = find(diff(q) ~= 0)'
    plot(t(j)*[1 1], yl, ':', 'color', [0.5 0.5 0.5]);
end
xlabel('t [s]'); ylabel('[mm]'); legend('x','y','location','northeast');
title('Head position (dotted: mode switches)');

subplot(2,2,4);
plot(t, wl, 'b', t, wr, 'r', 'linewidth', 1); grid on; hold on;
xlabel('t [s]'); ylabel('[rad/s]'); legend('\omega_l','\omega_r','location','northeast');
title('Angular velocity sensors');
set(f, 'PaperPositionMode', 'auto');
% Fit the wide four-panel overview on the PDF page without clipping it.
print(f, fullfile(outdir, 'q32_square.pdf'), '-dpdf', '-bestfit');
close all;
end
