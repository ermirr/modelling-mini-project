% MAIN_PART3  Q3.2 - drawing a square with the hybrid system.
clear;
clc;
close all;

P = printer_model();

sq.c0   = [0.02; 0.02];   % first corner [m]
sq.a    = 0.05;           % side [m]
sq.U    = 24;             % axis voltage on each side [V] (12 V per motor)
sq.epsw = 1e-3;           % tolerance of event S [rad/s]

sq.brakeAhead = true;
sim = square_hybrid(P, sq);
sq.brakeAhead = false;
simNaive = square_hybrid(P, sq);

% corner error = distance between the stop point of B_k and the corner c_k
pStop  = zeros(2, 4);  pNaive = zeros(2, 4);
for k = 1:4
    pStop(:,k)  = sim.p(find(sim.mode == 2*k, 1, 'last'), :)';
    pNaive(:,k) = simNaive.p(find(simNaive.mode == 2*k, 1, 'last'), :)';
end
err      = vecnorm(pStop  - sim.corners(:, 2:5));
errNaive = vecnorm(pNaive - simNaive.corners(:, 2:5));
fprintf('Q3.2 - square of side %.0f mm, U = %.0f V\n', 1e3*sq.a, sq.U);
fprintf('  braking distance d_b = %s um\n', mat2str(1e6*sim.db, 4));
fprintf('  corner error, brake in advance : %s um\n', mat2str(1e6*err, 3));
fprintf('  corner error, brake at corner  : %s um\n', mat2str(1e6*errNaive, 3));
fprintf('  total time %.2f s\n', sim.t(end));

modeNames = {'D_1','B_1','D_2','B_2','D_3','B_3','D_4','B_4'};

%% figure 1: path drawn in the plane
figure('Name', 'Q3.2 Square', 'NumberTitle', 'off');
sqx = sim.corners(1, :);  sqy = sim.corners(2, :);
plot(sqx, sqy, 'k--', 'LineWidth', 1); hold on;
plot(sim.p(:,1), sim.p(:,2), 'b', 'LineWidth', 1.5);
plot(sim.corners(1,1), sim.corners(2,1), 'ko', 'MarkerFaceColor', 'g');
axis equal; grid on;
xlim(sq.c0(1) + [-0.01, sq.a + 0.01]); ylim(sq.c0(2) + [-0.01, sq.a + 0.01]);
xlabel('x [m]'); ylabel('y [m]');
title('Path of the head (from the motor angles)');
legend('desired square', 'simulated path', 'start', 'Location', 'best');

%% figure 2: zoom on corner c_1, brake in advance vs brake at the corner
figure('Name', 'Q3.2 Corner zoom', 'NumberTitle', 'off');
c1 = sim.corners(:, 2);
plot(1e6*(simNaive.p(:,1) - c1(1)), 1e6*(simNaive.p(:,2) - c1(2)), 'r', ...
     'LineWidth', 1.5); hold on;
plot(1e6*(sim.p(:,1) - c1(1)), 1e6*(sim.p(:,2) - c1(2)), 'b', 'LineWidth', 1.5);
plot(0, 0, 'k+', 'MarkerSize', 12, 'LineWidth', 1.5);
xlim([-150 150]); ylim([-150 150]); axis square; grid on;
xlabel('x - x_{c1} [\mum]'); ylabel('y - y_{c1} [\mum]');
title('Zoom on corner c_1');
legend('brake at the corner', 'brake in advance (d_b)', 'corner c_1', ...
       'Location', 'best');

%% figure 3: time signals
figure('Name', 'Q3.2 Signals', 'NumberTitle', 'off');
subplot(4,1,1);
plot(sim.t, sim.p(:,1), sim.t, sim.p(:,2), 'LineWidth', 1.2);
ylabel('[m]'); legend('x', 'y'); grid on;
title('Head position');
subplot(4,1,2);
plot(sim.t, sim.eta(:,1), sim.t, sim.eta(:,2), 'LineWidth', 1.2);
ylabel('[rad]'); legend('\theta_l', '\theta_r'); grid on;
title('Angular sensors: motor angles');
subplot(4,1,3);
plot(sim.t, sim.um(:,1), sim.t, sim.um(:,2), 'LineWidth', 1.2);
ylabel('[V]'); legend('u_{m,l}', 'u_{m,r}'); grid on;
title('Motor voltages');
subplot(4,1,4);
stairs(sim.t, sim.mode, 'k', 'LineWidth', 1.2);
yticks(1:8); yticklabels(modeNames); ylim([0.5 8.5]);
xlabel('Time [s]'); grid on;
title('Active mode');
