function P = printer_model()
% PRINTER_MODEL  Parameters and state-space model of the two DC motors (Q1).
%
%   P = printer_model()
%
%   Same values and matrices as ex_1.m, collected in a struct so that they
%   can be used by the functions of Part 3.
%
%   State  eta = [theta_l; theta_r; omega_l; omega_r; i_l; i_r]
%   Input  u_m = [u_ml; u_mr]                 (motor voltages)
%   CoreXY p = p0 + rm*Pi*[theta_l; theta_r],  u_m = Pi*[u_x; u_y]

P.rm  = 0.01;     % [m]
P.Lm  = 0.003;    % [H]
P.Rm  = 2;        % [ohm]
P.Jm  = 5e-6;     % [kg*m^2]
P.Km  = 0.04;     % [N*m/A]
P.m   = 0.2;      % [kg]
P.mur = 0.03;     % [-]
P.mux = 0.035;    % [-]
P.muy = 0.04;     % [-]
P.rb  = 0.01;     % [m]
P.p0  = [0; 0];   % head position for theta_l = theta_r = 0 [m]

P.Jeq = P.Jm + 0.5*P.m*P.rm^2;
P.Bx  = (P.rm^2/2)*P.mux + 2*P.mur*(P.rm/P.rb)^2;
P.By  = (P.rm^2/2)*P.muy + 2*P.mur*(P.rm/P.rb)^2;
B1     = 0.5*(P.Bx + P.By);
Bcross = 0.25*P.rm^2*(P.mux - P.muy);

P.A = [0, 0, 1,              0,              0,            0;
       0, 0, 0,              1,              0,            0;
       0, 0, -B1/P.Jeq,      -Bcross/P.Jeq,  P.Km/P.Jeq,   0;
       0, 0, -Bcross/P.Jeq,  -B1/P.Jeq,      0,            P.Km/P.Jeq;
       0, 0, -P.Km/P.Lm,     0,              -P.Rm/P.Lm,   0;
       0, 0, 0,              -P.Km/P.Lm,     0,            -P.Rm/P.Lm];
P.B = [zeros(4,2); eye(2)/P.Lm];

P.Pi = 0.5*[1 1; 1 -1];   % CoreXY matrix (Q1.1, Q1.4)
end
