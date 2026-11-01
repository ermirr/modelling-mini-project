function plot_q31(L, P, outdir)
% PLOT_Q31  Figures of the filament-replacement simulation (Q3.1).
if nargin < 3, outdir = '.'; end
if ~exist(outdir, 'dir'), mkdir(outdir); end
Q = fr_modes();
% the log is decimated for figures 1 and 3 (keeps the PDF light)
t = L.t;  X = L.xi;  q = L.q;
wl = (X(:,2) + X(:,5))/P.rm;   wr = (X(:,2) - X(:,5))/P.rm;
ul = (L.u(:,1) + L.u(:,2))/2;  ur = (L.u(:,1) - L.u(:,2))/2;   % u_m = Pi*[ux;uy]

dec = unique([1:max(1, floor(numel(t)/6000)):numel(t), find(diff(q) ~= 0)', find(diff(q) ~= 0)' + 1]);
tD = t(dec);  XD = X(dec,:);  qD = q(dec);  uD = L.u(dec,:);
ulD = (uD(:,1) + uD(:,2))/2;  urD = (uD(:,1) - uD(:,2))/2;
% ---------------- Figure 1: overview -----------------------------------
f1 = figure('visible','off','position',[0 0 900 1000]);
set(f1, 'defaultaxesfontsize', 18, 'defaulttextfontsize', 18);
subplot(4,1,1);
stairs(tD, qD, 'k', 'linewidth', 2); grid on;
set(gca, 'ytick', 0:8, 'yticklabel', {'q_0','q_1','q_2^V','q_2^H','q_3','q_4','q_5','q_6','q_7'}, 'fontsize', 15);
ylim([-0.5 8.5]); xlim([0 t(end)]); title('Discrete mode q(t)');
subplot(4,1,2);
plot(tD, 1e3*XD(:,1), 'b', tD, 1e3*XD(:,4), 'r', 'linewidth', 2); grid on;
xlim([0 t(end)]); ylim([-10 1e3*P.dy+10]); set(gca,'ytick',[0 100 200]); ylabel('[mm]'); legend('x','y','location','east');
title('Head position');
subplot(4,1,3);
plot(tD, XD(:,7), 'linewidth', 2); hold on;
plot([0 t(end)], P.Thigh*[1 1], 'r--', [0 t(end)], P.Tlow*[1 1], 'b--', 'linewidth', 1.5);
grid on; xlim([0 t(end)]); ylim([130 220]); set(gca,'ytick',[140 170 210]); ylabel('T_n [°C]');
legend('T_n','T_{high}','T_{low}','location','southeast'); title('Nozzle temperature');
subplot(4,1,4);
plot(tD, ulD, 'b', tD, urD, 'r', tD, uD(:,3), 'k', 'linewidth', 1.5); grid on;
xlim([0 t(end)]); ylim([-3 26]); set(gca,'ytick',[0 12 24]); xlabel('t [s]'); ylabel('[V]');
legend('u_{m,l}','u_{m,r}','u_n','location','east'); title('Inputs');
set(f1, 'PaperPositionMode', 'auto');
% Keep the tall overview intact on a standard page instead of clipping it.
print(f1, fullfile(outdir, 'q31_overview.pdf'), '-dpdf', '-bestfit');

% ---------------- Figure 2: parking (first replacement) -----------------
i1 = find(q == Q.STOP, 1);  i2 = find(q == Q.WIPE, 1);
ta = t(i1) - 0.1;  tb = t(i2) + 0.15;
k = t >= ta & t <= tb;
sw = t(find(diff(q) ~= 0 & t(1:end-1) >= ta & t(1:end-1) <= tb));   % mode switches
f2 = figure('visible','off','position',[0 0 700 640]);
set(f2, 'defaultaxesfontsize', 20, 'defaulttextfontsize', 20);
subplot(3,1,1);
plot(t(k), 1e3*X(k,1), 'b', t(k), 1e3*X(k,4), 'r', 'linewidth', 2); grid on; hold on;
for j = 1:numel(sw), plot(sw(j)*[1 1], [-10 1e3*P.dy+10], 'k:'); end
xlim([ta tb]); ylim([-10 1e3*P.dy+10]); set(gca, 'ytick', [0 100 200]);
ylabel('[mm]'); legend('x','y'); title('Position (dotted: q_1, q_2^V, q_2^H, q_3 start)');
subplot(3,1,2);
plot(t(k), wl(k), 'b', t(k), wr(k), 'r', 'linewidth', 2); grid on; hold on;
wm = 1.3*max(abs([wl(k); wr(k)]));
for j = 1:numel(sw), plot(sw(j)*[1 1], [-wm wm], 'k:'); end
xlim([ta tb]); ylim([-wm wm]);
ylabel('[rad/s]'); legend('\omega_l','\omega_r'); title('Motor angular velocities');
subplot(3,1,3);
stairs(t(k), L.z(k), 'm', 'linewidth', 2.5); grid on; hold on;
for j = 1:numel(sw), plot(sw(j)*[1 1], [-0.3 3.3], 'k:'); end
set(gca, 'ytick', 0:3, 'yticklabel', {'q_0^p','q_1^p','q_2^p','q_3^p'});
ylim([-0.3 3.3]); xlim([ta tb]); xlabel('t [s]'); title('Detector A_p (Q2.2)');
set(f2, 'PaperPositionMode', 'auto');
print(f2, fullfile(outdir, 'q31_parking.pdf'), '-dpdf');

% ---------------- Figure 3: path in the plane ----------------------------
f3 = figure('visible','off','position',[0 0 520 520]);
set(f3, 'defaultaxesfontsize', 20, 'defaulttextfontsize', 20);
q = qD;  xx = 1e3*XD(:,1);  yy = 1e3*XD(:,4);
pr = (q == Q.PRINT);  pk = (q >= Q.STOP & q <= Q.MOVEH);  rs = (q == Q.RESUME);
msk = @(c) [xx, yy] .* (1 ./ double(c));         % NaN (Inf*0) outside class
P1 = msk(pr | [false; pr(1:end-1)]);  P2 = msk(pk | [false; pk(1:end-1)]);
P3 = msk(rs | [false; rs(1:end-1)]);
P1(~isfinite(P1)) = NaN;  P2(~isfinite(P2)) = NaN;  P3(~isfinite(P3)) = NaN;
plot(P1(:,1), P1(:,2), 'b', 'linewidth', 1.2); hold on;
plot(P2(:,1), P2(:,2), 'r', 'linewidth', 1.5);
plot(P3(:,1), P3(:,2), 'color', [0 0.6 0], 'linewidth', 1.2);
iS = find(diff(q) ~= 0 & q(2:end) == Q.STOP) + 1;
plot(xx(iS), yy(iS), 'ko', 'markersize', 7, 'linewidth', 1.5);
plot(0, 0, 'ks', 'markersize', 10, 'markerfacecolor', 'y');
axis equal; grid on; xlim([-10 1e3*P.dx+10]); ylim([-10 1e3*P.dy+10]);
xlabel('x [mm]'); ylabel('y [mm]');
legend('printing q_0','stop+parking','resume q_7', ...
       'saved s','wipe tower','location','northwest');

set(f3, 'PaperPositionMode', 'auto');
print(f3, fullfile(outdir, 'q31_path.pdf'), '-dpdf');
close all;
end
