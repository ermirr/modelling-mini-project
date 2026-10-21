function [parked, stateTrace] = park_detector(sigma)
% PARK_DETECTOR  DFA used as head-parked detector (Q2.2).
%
%   [parked, stateTrace] = park_detector(sigma)
%
%   sigma      : N-by-2 matrix, row k is the sample sigma_k = (M_k, m_k)
%                M_k = 1 for H (horizontal), 2 for V (vertical)
%                m_k = 1 for '+' (motor rotating), 0 for '0' (not rotating)
%   parked     : true if the run of the automaton ends in the accept state q2
%   stateTrace : visited states q_0, q_1, ..., q_N (numbers 0, 1, 2)
%
%   States: q0 = bottom edge not detected
%           q1 = bottom edge detected (y = 0)
%           q2 = head parked in (0,0)  (accept state)
%
%   Example: park_detector([2 1; 2 0; 1 1; 1 0])  -> true
%            (sequence (V,+)(V,0)(H,+)(H,0))

if size(sigma,2) ~= 2 || any(~ismember(sigma(:,1), [1 2])) || ...
        any(~ismember(sigma(:,2), [0 1]))
    error('park_detector: sigma must be N-by-2, M in {1,2} and m in {0,1}');
end

% transition function delta(q, s)
% rows: q0, q1, q2    columns: (H,+) (H,0) (V,+) (V,0)
delta = [0 0 0 1;
         1 2 0 1;
         1 2 0 2];
F = 2;                      % accept state

N = size(sigma,1);
q = 0;                      % initial state q0
stateTrace = zeros(N+1,1);
stateTrace(1) = q;
for k = 1:N
    s = 2*(sigma(k,1)-1) + 2 - sigma(k,2);   % column index of the symbol
    q = delta(q+1, s);
    stateTrace(k+1) = q;
end
parked = (q == F);
end
