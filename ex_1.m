clc;
clear;
close all;

% PARAMETERS - found by consulting datasheets of components presented on
% corexy.com
rm = 0.01;    % [m]
Lm = 0.003;   % [H]
Rm = 2;       % [ohm]
Jm = 5*10^-6; % [Kg*m^2]
Km = 0.04;    % [N*m/A]
m = 0.2;      % [Kg]
mur = 0.03;   % [-]
mux = 0.035; % [-]
muy = 0.04;  % [-]
rb = 0.01;    % []
dx = 0.02;    % [m]
dy = 0.02;    % [m]

x0 = 0; % [m]
y0 = 0; % [m]

%Q1.1
%x = x0 + rm / 2 * (theta_l + theta_r); % [m]
%y = y0 + rm / 2 * (theta_l - theta_r); % [m]

%state-space model Q2.2

Jeq = Jm + 0.5 * m * rm^2;

Bx = (rm^2 / 2) * mux + 2 * mur * (rm / rb)^2;
By = (rm^2 / 2) * muy + 2 * mur * (rm / rb)^2;

B1 = 0.5 * (Bx + By);
B_cross = 0.25 * rm^2 * (mux - muy);

A_sys = [
    0, 0, 1,            0,            0,      0;
    0, 0, 0,            1,            0,      0;
    0, 0, -B1/Jeq,      -B_cross/Jeq, Km/Jeq, 0;
    0, 0, -B_cross/Jeq, -B1/Jeq,      0,      Km/Jeq;
    0, 0, -Km/Lm,       0,            -Rm/Lm, 0;
    0, 0, 0,            -Km/Lm,       0,      -Rm/Lm
];
B_sys = [
    0,    0;
    0,    0;
    0,    0;
    0,    0;
    1/Lm, 0;
    0,    1/Lm
];
C_sys = [
  0, 0, 1, 1, 1, 0 % I might be intersted in the velocity of the motors and the current
];
D_sys = 0;

sys = ss(A_sys, B_sys, C_sys, D_sys);
sys.StateName = {'theta_l', 'theta_r', 'dtheta_l', 'dtheta_r', 'i_ml', 'i_mr'};
sys.InputName = {'um_l', 'um_r'};

% state-space models Q2.3
% x - motion
Ax = [
    0, 1,                     0;
    0, -Bx/Jeq,               (rm * Km) / (2 * Jeq);
    0, (-2 * Km) / (Lm * rm), -Rm / Lm
];
Bx_sys = [
    0;
    0;
    1 / Lm
];
Cx = [
    1, 0, 0
];
Dx = 0;

sys_x = ss(Ax, Bx_sys, Cx, Dx);
sys_x.StateName = {'x', 'dot_x', 'i_x'};
sys_x.InputName = {'u_x'};

% y - motion

Ay = [
    0, 1,                     0;
    0, -By/Jeq,               (rm * Km) / (2 * Jeq);
    0, (-2 * Km) / (Lm * rm), -Rm / Lm
];
By_sys = [
    0;
    0;
    1 / Lm
];
Cy = [
  1, 0, 0  
];
Dy = 0;

sys_y = ss(Ay, By_sys, Cy, Dy);
sys_y.StateName = {'y', 'dot_y', 'i_y'};
sys_y.InputName = {'u_y'};

%Q1.4

t = linspace(0, 4*pi, 2000);
dt = t(2) - t(1);
omega = 0.5;
A_ell = 0.1;
B_ell = 0.05;

x_ell = dx / 2 + A_ell * cos(omega * t);
y_ell = dy / 2 + B_ell * sin(omega * t);

dx = -A_ell * omega * sin(omega * t);
ddx = -A_ell * (omega^2) * cos(omega * t);
dddx = A_ell * (omega^3) * sin(omega * t);

ix = (2 / (rm * Km)) * (Jeq * ddx + Bx * dx);
dix = (2 / (rm * Km)) * (Jeq * dddx + Bx * ddx);
    
ux_ell = Lm * dix + Rm * ix + (2 * Km / rm) * dx;
    
dy = B_ell * omega * cos(omega * t);
ddy = -B_ell * (omega^2) * sin(omega * t);
dddy = -B_ell * (omega^3) * cos(omega * t);

iy = (2 / (rm * Km)) * (Jeq * ddy + By * dy);
diy = (2 / (rm * Km)) * (Jeq * dddy + By * ddy);

uy_ell = Lm * diy + Rm * iy + (2 * Km / rm) * dy;
    
um_l_ell = (ux_ell + uy_ell) / 2;
um_r_ell = (ux_ell - uy_ell) / 2;

x_sim_ell = lsim(sys_x, ux_ell, t, [x_ell(1); 0; 0]);
y_sim_ell = lsim(sys_y, uy_ell, t, [y_ell(1); 0; 0]);

figure('Name','Q1.4 Trajectories & Inputs','NumberTitle','off');

subplot(2,2,1);
plot(x_sim_ell, y_sim_ell, 'b', 'LineWidth', 1);
title('Elliptic Path'); xlabel('X [m]'); ylabel('Y [m]');
xlim([0, dx]);
ylim([0, dy]);
axis equal;
grid on;

subplot(2,2,2);
plot(t, um_l_ell, 'g', t, um_r_ell, 'm', 'LineWidth', 1.2);
title('Motor Voltages (Ellipse)'); xlabel('Time [s]'); ylabel('Voltage [V]');
legend('u_{m,l}', 'u_{m,r}');
grid on;

% ADDITIONAL FIGURE MISSING
% REMEMBER TO EXPLAIN THE CHOICE OF OMEGA IN RELATION WITH INPUT VOLTAGES
% (COREXY DATASHEETS)