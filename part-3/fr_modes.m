function Q = fr_modes()
% FR_MODES  Mode numbers of the hybrid automaton H_f (Q3.1).
Q.PRINT = 0;  Q.STOP = 1;  Q.MOVEV = 2;  Q.MOVEH = 3;  Q.WIPE = 4;
Q.HOFF  = 5;  Q.LOAD = 6;  Q.HON   = 7;  Q.RESUME = 8;
Q.names = {'q_0 Printing','q_1 Stop-save','q_2^V Move V','q_2^H Move H', ...
           'q_3 Wipe','q_4 Heater-off','q_5 Load','q_6 Heater-on','q_7 Resume'};
end
