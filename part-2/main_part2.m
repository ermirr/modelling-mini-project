% MAIN_PART2  Examples for Part 2 of the mini project (Q2.1 and Q2.2).
clear; 
clc;

%% Q2.1 - Filament replacement (Moore machine)
% one complete replacement started by C, then back to printing
ev = {'C','done','done','done','done','done','done','done'};
[states, outputs] = filament_fsm(ev);
fprintf('Q2.1 - input: %s\n', strjoin(ev, ' '));
for k = 1:numel(states)
    fprintf('  step %d  %-16s %s\n', k-1, states{k}, outputs{k});
end

% a new C or F during the procedure is ignored (self-loop)
ev2 = {'F','done','C','done'};
states2 = filament_fsm(ev2);
fprintf('\nQ2.1 - input: %s\n', strjoin(ev2, ' '));
fprintf('  states: %s\n', strjoin(states2', ' -> '));