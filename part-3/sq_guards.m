function [val, dir] = sq_guards(t, q, xi, mem, P)
% SQ_GUARDS  No guard of Q3.2 depends on unmeasured quantities: all the
% guards use the angular sensors and are evaluated at the samples.
val = 1;  dir = 0;
end
