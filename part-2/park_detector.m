function [parked, stateTrace] = park_detector(sigma)
% PARK_DETECTOR  DFA used as head-parked detector (Q2.2).
%
%   [parked, stateTrace] = park_detector(sigma)
%
%   sigma      : N-by-2 matrix, row k is the sample sigma_k = (M_k, m_k)
%                M_k = 1 for H (horizontal), 2 for V (vertical)
%                m_k = 1 for '+' (motor rotating), 0 for '0' (not rotating)
%   parked     : true if the run of the automaton ends in the accept state q3
%   stateTrace : visited states q_0, q_1, ..., q_N (numbers 0..3)
%
%   States: q0 = no edge known
%           q1 = bottom edge known (y = 0)
%           q2 = left edge known   (x = 0)
%           q3 = head parked in (0,0)  (accept state)
%   (H,+) destroys the information on x, (V,+) the one on y; (H,0) gives
%   x = 0 and (V,0) gives y = 0. The motions can come in any order.
%
%   Example: park_detector([1 1; 2 1; 1 1; 1 0; 2 1; 2 0])  -> true
%            (sequence (H,+)(V,+)(H,+)(H,0)(V,+)(V,0) of the assignment)

if size(sigma,2) ~= 2 || any(~ismember(sigma(:,1), [1 2])) || ...
        any(~ismember(sigma(:,2), [0 1]))
    error('park_detector: sigma must be N-by-2, M in {1,2} and m in {0,1}');
end

N = size(sigma,1);
q = 0;                      % initial state q0
stateTrace = zeros(N+1,1);
stateTrace(1) = q;
for k = 1:N
    q = park_detector_step(q, sigma(k,1), sigma(k,2));
    stateTrace(k+1) = q;
end
parked = (q == 3);          % accept state q3
end
