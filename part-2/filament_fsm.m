function [stateTrace, outputTrace] = filament_fsm(events)
% FILAMENT_FSM  Moore machine for the filament replacement (Q2.1).
%
%   [stateTrace, outputTrace] = filament_fsm(events)
%
%   events      : cell array (or string array) with the input symbols
%                 'C'    = new colour required
%                 'F'    = spool finished
%                 'done' = the action of the current state is completed
%   stateTrace  : visited states q_0, q_1, ..., q_n
%   outputTrace : output lambda(q_k) of each visited state (Moore machine)
%
%   Inputs not enabled in a state leave the state unchanged (self-loop).
%
%   Example: filament_fsm({'C','done','done','done','done','done','done','done'})
%            goes through q0 ... q7 and comes back to q0.

if isstring(events) || ischar(events)
    events = cellstr(events);
elseif iscellstr(events)
    events = events(:);
else
    error('filament_fsm: events must be a string array, a character array or a cell array of character vectors');
end
n = numel(events);

stateNames = {'q0 printing', 'q1 stop-save', 'q2 move-to-wipe', 'q3 wipe', ...
              'q4 heater-off', 'q5 load', 'q6 heater-on', 'q7 resume'};
lambda = {'print', ...
     'stop printing and save (x,y)', ...
     'move head to wipe tower (xp,yp) = (0,0)', ...
     'print on wipe tower to remove excess filament', ...
     'switch nozzle heater off', ...
     'load new filament', ...
     'switch nozzle heater on', ...
     'move head back to (x,y) and resume printing'};

% transition function delta(q, s)
% rows: q0 ... q7    columns: C, F, done
delta = [1 1 0;
         1 1 2;
         2 2 3;
         3 3 4;
         4 4 5;
         5 5 6;
         6 6 7;
         7 7 0];

q = 0;                              % initial state q0
stateTrace  = cell(n+1,1);
outputTrace = cell(n+1,1);
stateTrace{1}  = stateNames{q+1};
outputTrace{1} = lambda{q+1};
for k = 1:n
    switch events{k}
        case 'C'
            s = 1;
        case 'F'
            s = 2;
        case 'done'
            s = 3;
        otherwise
            error('filament_fsm: unknown input ''%s'' at step %d', events{k}, k);
    end
    q = delta(q+1, s);
    stateTrace{k+1}  = stateNames{q+1};
    outputTrace{k+1} = lambda{q+1};
end
end
