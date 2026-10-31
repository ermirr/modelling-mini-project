function [parked, stateTrace] = park_detector(sigma)
% PARK_DETECTOR  DFA used as head-parked detector (Q2.2).
%
%   [parked, stateTrace] = park_detector(sigma)
%
%   sigma      : N-by-2 matrix, row k is the sample sigma_k = (M_k, m_k)
%                M_k = 1 for H (horizontal), 2 for V (vertical)
%                m_k = 1 for '+' (motor rotating), 0 for '0' (not rotating)
%   parked     : true if the run of the automaton ends in the accept state q3
%   stateTrace : visited states q_0, q_1, ..., q_N (numbers 0, 1, 2, 3)
%
%   Assumption: the commands have known directions
%   H moves the head to the left and V moves it downwards; the order of the
%   two motions is free and they can be interleaved. Then
%     (H,0) -> head at the left side (x = 0)
%     (V,0) -> head at the bottom    (y = 0)
%     (H,+) -> head moving to the left, so it is not at the left side
%     (V,+) -> head moving downwards, so it is not at the bottom
%   A horizontal motion does not change y, a vertical motion does not change x.
%   For another corner the same table is used, with the directions of the two
%   commands changed (e.g. H to the right and V upwards for the top-right).
%
%   States: q0 = no edge detected
%           q1 = left edge detected   (x = 0)
%           q2 = bottom edge detected (y = 0)
%           q3 = head parked in (0,0) (accept state)
%   The string is accepted iff its last H symbol is (H,0) and its last V
%   symbol is (V,0).
%
%   Example: park_detector([1 1; 2 1; 1 1; 1 0; 2 1; 2 0])  -> true
%            (sequence of the assignment (H,+)(V,+)(H,+)(H,0)(V,+)(V,0))

if size(sigma,2) ~= 2 || any(~ismember(sigma(:,1), [1 2])) || ...
        any(~ismember(sigma(:,2), [0 1]))
    error('park_detector: sigma must be N-by-2, M in {1,2} and m in {0,1}');
end

% transition function delta(q, s)
% rows: q0, q1, q2, q3    columns: (H,+) (H,0) (V,+) (V,0)
delta = [0 1 0 2;
         0 1 1 3;
         2 3 0 2;
         2 3 1 3];
F = 3;                      % accept state

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
