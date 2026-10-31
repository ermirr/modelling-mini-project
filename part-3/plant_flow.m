function dxi = plant_flow(xi, u, wall, P)
% PLANT_FLOW  sys(x,u): continuous dynamics of the printer (Q1 models).
%   xi   = [x vx ix y vy iy Tn Vcn in ell tau tp]'   (12 x 1)
%          (x,vx,ix) and (y,vy,iy): decoupled CoreXY model of Q1.3
%          (Tn,Vcn,in): nozzle model of Q1.5
%          ell: filament used, tau: clock, tp: printing-progress clock
%   u    = [ux uy un e tpdot]'  axis voltages, nozzle voltage,
%          extrusion rate, rate of tp (1 while printing, else 0)
%   wall = [wx wy], 0 = free, -1 = against lower wall, +1 = upper wall
x  = xi(1);  vx = xi(2);  ix = xi(3);                    %#ok<NASGU>
vy = xi(5);  iy = xi(6);
Tn = xi(7);  V  = xi(8);  in = xi(9);
g  = P.Km*P.rm/(2*P.Jeq);          % current -> acceleration
kb = 2*P.Km/P.rm;                  % back-emf in axis coordinates

dxi = zeros(12,1);
% x axis
dxi(1) = vx;
dxi(2) = -P.Bfx/P.Jeq*vx + g*ix;
dxi(3) = (-P.Rm*ix - kb*vx + u(1))/P.Lm;
% y axis
dxi(4) = vy;
dxi(5) = -P.Bfy/P.Jeq*vy + g*iy;
dxi(6) = (-P.Rm*iy - kb*vy + u(2))/P.Lm;
% frame contact: the axis is blocked (v = 0), the current still evolves
if wall(1) ~= 0, dxi(1) = 0; dxi(2) = 0; end
if wall(2) ~= 0, dxi(4) = 0; dxi(5) = 0; end
% nozzle (Q1.5)
dxi(7) = (V^2/P.Rn - (Tn - P.Te)/P.Rtn)/P.Ctn;
dxi(8) = (in - V/P.Rn)/P.Cn;
dxi(9) = (u(3) - V)/P.Ln;
% filament, clocks
dxi(10) = u(4);
dxi(11) = 1;
dxi(12) = u(5);
end
