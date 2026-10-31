function P = params_printer()
% PARAMS_PRINTER  Parameters used in Part 3.
% The Q1 parameters are in printer_model.m (same values as ex_1.m);
% here the nozzle and the parameters of the events are added.
here = fileparts(mfilename('fullpath'));
addpath(fullfile(here, '..', 'part-2'));    % park_detector_step

% ---- CoreXY + DC motors (Q1) ------------------------------------------
P = printer_model();
P.Bfx = P.Bx;                % B_{f,x} = B_eq + B_c  (Q1.3)
P.Bfy = P.By;                % B_{f,y} = B_eq - B_c

% ---- Nozzle (Q1.5) ----------------------------------------------------
P.Ln  = 10e-3;      % [H]
P.Cn  = 1e-3;       % [F]
P.Rn  = 10;         % [Ohm]
P.Ctn = 5;          % [J/K]
P.Rtn = 4;          % [K/W]
P.Te  = 25;         % [degC]
P.Un_max = 24;      % [V]   heater voltage in "Heater-on" (boost)

% ---- Events / thresholds (Part 3) ------------------------------------
P.Thigh = 210;      % [degC] nozzle temperature high (event 4)
P.Tlow  = 170;      % [degC] nozzle temperature low  (event 5)
P.Un_hold = sqrt(P.Rn*(P.Thigh - P.Te)/P.Rtn);  % keeps Tn = Thigh
P.alpha = 0.0333;   % [-]   filament length per unit path (0.4x0.2 mm bead, 1.75 mm filament)
P.Ls    = 330;      % [m]   filament on one spool (1 kg PLA)
P.vw    = 2e-3;     % [m/s] filament feed while wiping
P.Tw    = 3;        % [s]   wiping time       (event 3)
P.Tld   = 5;        % [s]   loading time
P.Tm    = 8;        % [s]   duration of the move back to s
P.Up    = 24;       % [V]   parking voltage (axis voltage, 12 V per motor)
P.Ts    = 5e-3;     % [s]   sampling period of the supervisor
P.epsw  = 0.2;      % [rad/s] "motor not rotating" threshold
P.irel  = 1e-6;     % [A]   current above which the head leaves the frame
P.epsp  = 1e-4;     % [m]   arrival tolerance on the position (Q3.2)

end
