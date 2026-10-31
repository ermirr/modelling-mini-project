function S = sq_modes()
% SQ_MODES  Mode numbers of the square-drawing automaton (Q3.2).
S.HOMEV = 0; S.HOMEH = 1; S.GOTO = 2; S.SIDE1 = 3; S.SIDE2 = 4;
S.SIDE3 = 5; S.SIDE4 = 6; S.DONE = 7;
S.names = {'Home V','Home H','Go to A','Side AB','Side BC','Side CD','Side DA','Done'};
end
