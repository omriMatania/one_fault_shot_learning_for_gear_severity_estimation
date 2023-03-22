function [sim_tuning_param] = load_simulation_tuning_param()
% load_simulation_tuning_param loads the parameters for the simulation
% tuning process which addresses the  differences between the simultion and the
% reality

sim_tuning_param.sim_faults_div = 0.01 ; % maximal deviation between the selected one faluty exampel and the corresponding training set example 
sim_tuning_param.possible_DIN_param = [1 : 1 : 12] ; % possible DIN parameters for tuning the diffrences between the simulation and the reality.

end % of load_simulation_tuning_param

