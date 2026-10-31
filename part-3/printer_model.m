function P = printer_model()
% PRINTER_MODEL  Parameters of the CoreXY motors (Q1), same values as ex_1.m
% (datasheets on corexy.com), collected in a struct for Part 3.

P.rm  = 0.01;     % [m]          motor pulley radius
P.Lm  = 0.003;    % [H]          motor inductance
P.Rm  = 2;        % [ohm]        motor resistance
P.Jm  = 5e-6;     % [kg*m^2]     motor inertia
P.Km  = 0.04;     % [N*m/A]      motor constant
P.m   = 0.2;      % [kg]         tool head mass
P.mur = 0.03;     % [N*m*s/rad]  rolling bearing friction (rotational)
P.mux = 0.035;    % [N*s/m]      linear bearing friction, x
P.muy = 0.04;     % [N*s/m]      linear bearing friction, y
P.rb  = 0.01;     % [m]          bearing pulley radius
P.dx  = 0.2;      % [m]          print area, x
P.dy  = 0.2;      % [m]          print area, y

P.Jeq = P.Jm + 0.5*P.m*P.rm^2;
P.Bx  = (P.rm^2/2)*P.mux + 2*P.mur*(P.rm/P.rb)^2;   % B_{f,x} of Q1.3
P.By  = (P.rm^2/2)*P.muy + 2*P.mur*(P.rm/P.rb)^2;   % B_{f,y} of Q1.3
end