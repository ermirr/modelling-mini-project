clc;
clear; 
close all;

% Parameters
c = 0.002;           % filament square section [m]
A = c^2;             % filament square area [m^2]
L_tot = 0.5;         % Total length of the print [m]
v_print = 0.05;      % nozzle's print velocity [m/s]

% filament's material parameters (Assumed the filament is made of PLA)
rho = 1245;             % Density [kg/m^3]
cp = 1600;              % Specific heat capacity [J/(kg·K)]
k = 0.16;               % Thermal conductivity [W/(m·K)]
alpha = k / (rho * cp); % Thermal diffusivity [m^2/s]

% Boundary and environmental parameters
T_nozzle = 210;      % Extrusion temperature (nozzle) [°C]
T_plate = 60;        % Heated bed temperature [°C]
T_env = 20;          % Ambient air temperature [°C]
h_plate = 15;        % Heat transfer coefficient with the plate [W/(m^2·K)]
h_env = 10;          % Heat transfer coefficient with ambient air on 3 sides [W/(m^2·K)]

% Spatial discretization
N_tot = 100;         % Total number of cells for the entire path
dx = L_tot / N_tot;  % Spatial step [m]
V = c^2 * dx;        % Volume of a single cell [m^3]
C_th = rho * cp * V; % Thermal capacity of the cell [J/K]

% 3. Time discretization and stability
t_print = L_tot / v_print; % Total printing time

% Thermal stability conditions (CFL)
dt_diff = (dx^2) / (2 * alpha);
dt_conv = C_th / (h_plate * c * dx + 3 * h_env * c * dx);
dt_movement = dx / v_print; %constraint on advancing 1 cell per step
dt = 0.5 * min([dt_diff, dt_conv, dt_movement]); 

t_cool_extra = 30;   % Cooling period after printing is complete
t_max = t_print + t_cool_extra; % Total simulation time
time_vec = 0:dt:t_max;
num_steps = length(time_vec);

% Simulation
% Initialization
T = T_env * ones(N_tot, 1);     % Cell temperature vector 
N_active = 0;                   % Number of currently deposited cells
T_history = T_env * ones(N_tot, num_steps); % Matrix to save the temperature history over time

% Loop
for step = 1:num_steps
    t = time_vec(step);
    
    % growing domain phase
    if t <= t_print
        x_nozzle = v_print * t;
        target_active = min(N_tot, ceil(x_nozzle / dx));
        while N_active < target_active
            N_active = N_active + 1;
            T(N_active) = T_nozzle;
        end
    end
    
    % thermal evolution
    if N_active > 0
        Phi = zeros(N_active + 1, 1);
        Phi(1) = 0;
        for i = 2:N_active
            Phi(i) = -k * A * (T(i) - T(i-1)) / dx;
        end
        Phi(N_active + 1) = 0; 
        T_new = T;
        
        for i = 1:N_active
            net_conduction = Phi(i) - Phi(i+1);
            
            Q_ext_plate = -h_plate * c * dx * (T(i) - T_plate);
            Q_ext_env   = -3 * h_env * c * dx * (T(i) - T_env);
            Q_ext_tot   = Q_ext_plate + Q_ext_env;
            
            if t <= t_print && i == N_active
                T_new(i) = T_nozzle; 
            else
                T_new(i) = T(i) + (dt / C_th) * (net_conduction + Q_ext_tot);
            end
        end
        T = T_new;
    end
    T_history(:, step) = T;
end

% plot
figure('Color', 'white');
imagesc(time_vec, (1:N_tot)*dx, T_history);
set(gca, 'YDir', 'normal');
colorbar;
xlabel('Time [s]');
ylabel('Position along the filament x [m]');
colormap('jet');
