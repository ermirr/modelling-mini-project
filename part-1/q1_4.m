clc;
clear;
close all;

% PARAMETERS - found by consulting datasheets of components presented on corexy.com
rm = 0.01;    % [m]
Lm = 0.003;   % [H]
Rm = 2;       % [ohm]
Jm = 5*10^-6; % [Kg*m^2]
Km = 0.04;    % [N*m/A]
m = 0.2;      % [Kg]
mur = 0.03;   % [-]
mux = 0.035;  % [-]
muy = 0.04;   % [-]
x_dim = 0.2;  % [m]
y_dim = 0.2;  % [m]
x0 = 0;       % [m]
y0 = 0;       % [m]

Jeq = Jm + 0.5 * m * rm^2;
Beq = (rm^2 / 4) * (mux + muy) + 2 * mur;
Bc  = (rm^2 / 4) * (mux - muy);
Bx = Beq + Bc;
By = Beq - Bc;

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
Cx = [1, 0, 0];
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
Cy = [1, 0, 0];
Dy = 0;
sys_y = ss(Ay, By_sys, Cy, Dy);
sys_y.StateName = {'y', 'dot_y', 'i_y'};
sys_y.InputName = {'u_y'};

% ellipse
t = linspace(0, 4*pi, 2000);
dt = t(2) - t(1);
omega = 0.5;
A_ell = 0.1;
B_ell = 0.05;

x_ell = x_dim / 2 + A_ell * cos(omega * t);
dx = -A_ell * omega * sin(omega * t); 
ddx = -A_ell * (omega^2) * cos(omega * t);
dddx = A_ell * (omega^3) * sin(omega * t);

ix = (2 / (rm * Km)) * (Jeq * ddx + Bx * dx);
dix = (2 / (rm * Km)) * (Jeq * dddx + Bx * ddx);
ux_ell = Lm * dix + Rm * ix + (2 * Km / rm) * dx;
    
y_ell = y_dim / 2 + B_ell * sin(omega * t);
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

% star
omega_star = 0.5; 
R_star = 0.025;   

x_star = x_dim / 2 + R_star * (2*cos(omega_star * t) + 0.5*cos(4*omega_star * t) + 0.5*cos(6*omega_star * t));
dx_star = R_star * omega_star * (-2*sin(omega_star * t) - 2*sin(4*omega_star * t) - 3*sin(6*omega_star * t));
ddx_star = R_star * omega_star^2 * (-2*cos(omega_star * t) - 8*cos(4*omega_star * t) - 18*cos(6*omega_star * t));
dddx_star = R_star * omega_star^3 * (2*sin(omega_star * t) + 32*sin(4*omega_star * t) + 108*sin(6*omega_star * t));

ix_star = (2 / (rm * Km)) * (Jeq * ddx_star + Bx * dx_star);
dix_star = (2 / (rm * Km)) * (Jeq * dddx_star + Bx * ddx_star);
ux_star = Lm * dix_star + Rm * ix_star + (2 * Km / rm) * dx_star;

y_star = y_dim / 2 + R_star * (2*sin(omega_star * t) - 0.5*sin(4*omega_star * t) + 0.5*sin(6*omega_star * t));
dy_star = R_star * omega_star * (2*cos(omega_star * t) - 2*cos(4*omega_star * t) + 3*cos(6*omega_star * t));
ddy_star = R_star * omega_star^2 * (-2*sin(omega_star * t) + 8*sin(4*omega_star * t) - 18*sin(6*omega_star * t));
dddy_star = R_star * omega_star^3 * (-2*cos(omega_star * t) + 32*cos(4*omega_star * t) - 108*cos(6*omega_star * t));

iy_star = (2 / (rm * Km)) * (Jeq * ddy_star + By * dy_star);
diy_star = (2 / (rm * Km)) * (Jeq * dddy_star + By * ddy_star);
uy_star = Lm * diy_star + Rm * iy_star + (2 * Km / rm) * dy_star;

um_l_star = (ux_star + uy_star) / 2;
um_r_star = (ux_star - uy_star) / 2;

x_sim_star = lsim(sys_x, ux_star, t, [x_star(1); dx_star(1); ix_star(1)]);
y_sim_star = lsim(sys_y, uy_star, t, [y_star(1); dy_star(1); iy_star(1)]);

% plot
figure('Name','Q1.4 Trajectories & Inputs','NumberTitle','off');

subplot(2,2,1);
plot(x_sim_ell, y_sim_ell, 'b', 'LineWidth', 1);
title('Elliptic Path'); xlabel('X [m]'); ylabel('Y [m]');
xlim([0, x_dim]); ylim([0, y_dim]);
axis equal; grid on;

subplot(2,2,2);
plot(t, um_l_ell, 'g', t, um_r_ell, 'm', 'LineWidth', 1.2);
title('Motor Voltages (Ellipse)'); xlabel('Time [s]'); ylabel('Voltage [V]');
legend('u_{m,l}', 'u_{m,r}');
grid on;

subplot(2,2,3);
plot(x_sim_star, y_sim_star, 'r', 'LineWidth', 1);
title('Star Path'); xlabel('X [m]'); ylabel('Y [m]');
xlim([0, x_dim]); ylim([0, y_dim]);
axis equal; grid on;

subplot(2,2,4);
plot(t, um_l_star, 'g', t, um_r_star, 'm', 'LineWidth', 1.2);
title(sprintf('Motor Voltages (Star)', omega_star)); 
xlabel('Time [s]'); ylabel('Voltage [V]');
legend('u_{m,l}', 'u_{m,r}');
grid on;