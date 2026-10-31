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

%% Q2.2 - Head-parked detector (DFA)
% each row is a sample [M m]: M = 1 (H), 2 (V); m = 1 (+), 0 (0)
H = 1; V = 2;
tests = { [H 1; V 1; H 1; H 0; V 1; V 0],     '(H,+)(V,+)(H,+)(H,0)(V,+)(V,0)';
          [V 1; V 0; H 1; H 0],               '(V,+)(V,0)(H,+)(H,0)';
          [V 0; H 0],                         '(V,0)(H,0)';
          [V 0; H 0; V 0],                    '(V,0)(H,0)(V,0)';
          [V 0; H 0; H 1],                    '(V,0)(H,0)(H,+)';
          [V 0; H 0; V 1; V 1],               '(V,0)(H,0)(V,+)(V,+)';
          [H 0; V 1; H 0; V 0],               '(H,0)(V,+)(H,0)(V,0)'
          };
fprintf('\nQ2.2\n');
for i = 1:size(tests,1)
    [parked, run] = park_detector(tests{i,1});
    fprintf('  %-34s parked = %d   run: %s\n', tests{i,2}, parked, ...
            sprintf('q%d ', run));
end
 