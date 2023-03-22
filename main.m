%{
This code implements the study presented in "One-fault-shot learning
for fault severity estimation in gears by addressing simulation and reality
differences and transfer function effects".

All the codes of this work and the available datasets (simulated and experimental)
can be used for any academic purpose. However, if you use part of the codes or
the data you need to cite:
[1] Matania, O., Bachar, L., Khemani, V., Das, D., Azarian, M. H., & Bortman, J. 
"One-fault-shot learning for fault severity estimation of gears that addresses 
differences between simulation and experimental signals and transfer function effects."
Advanced Engineering Informatics 2023;56, 101945. https://doi.org/10.1016/J.AEI.2023.101945

If you use the code of ACS you need to cite also:
[2] Matania O, Klein R, Bortman J. "Novel approaches for the estimation of
    the spectrum background for stationary and quasi-stationary signals." 
    Mech Syst Signal Process 2022;167. https://doi.org/10.1016/j.ymssp.2021.108503."
[3] Matania O, Klein R, Bortman J. "Algorithms for spectrum background
    estimation of non-stationary signals." Mech Syst Signal Process 2022;167.
    https://doi.org/10.1016/j.ymssp.2021.108551
	
If you use the code for propagation the signals via the estimated transfer function you should cite:
[4] Matania O, Klein R, Bortman J. "Transfer Across Different Machines by Transfer Function Estimation."
	Front Artif Intell 2022. https://doi.org/10.3389/FRAI.2022.811073.

All the code is initiated from this main script. All you need to do is put 
all the data from "here" (the same data as in the Readme file) in the designated
path and set a directory for the processed data. The directory for the processed 
data enables the algorithm to process each calculation only once, thus saving running time.

You can change the speed and load in the operating
condition section. There are 4 options:
Speed 15rps, Load 5Nm
Speed 15rps, Load 10Nm
Speed 30rps, Load 5Nm
Speed 30rps, Load 10Nm
Furthermore, you can decide if to address the attenuation effect and the
varied gain and amplitude.

In Section 3 of this script, the internal parameters of the code are loaded.
These parameters should not be changed by the user. There were no checks to 
ensure that the available codes will work with other parameters, and as a result,
the process may fail.

The codes were run and tested on MATLAB 2016a and MATLAB 2022b.

For any question you can send an email to Omri Matania: omrimatania@gmail.com
%}

clear all; close all;

% ----------------------------------------------------------------------- %
% Section 1: Set the directory path of the data and the processed data
% ----------------------------------------------------------------------- %

data_dic_path = 'C:\data\one_fault_shot_learning_for_gear_severity_estimation\data' ;
processed_data_dic_path = 'C:\data\one_fault_shot_learning_for_gear_severity_estimation\processed_data' ;

% ----------------------------------------------------------------------- %
% Section 2: Set the parameters
% ----------------------------------------------------------------------- %

rotating_speed = 15 ; % rps. Possible speeds: 15rps, 30rps.
system_load = 10 ; % Nm. Possible loads: 5Nm, 10Nm.

% Set 1 for use the operation, 0 to not
use_RMS_normalization = 1 ;
mitigate_varied_gain_phase = 1 ;

% If you want to use the same random numbers in each operation of the codes
% use this line, otherwise put it as a comment.
rng('default')

tic() % for display times along the running of the codes

% ----------------------------------------------------------------------- %
% Section 3: Load internal parameters 
% ----------------------------------------------------------------------- %

data_path = [data_dic_path,'\'] ;
processed_data_path = [processed_data_dic_path,'\'] ;

num_points_SA_sig = 2048 ;
num_winds_4_calc_SA_sig = 50 ;
test_exp_exmpl_ind = 2000 ;
delays_ups_num_pnts = 100 ;
%DIN_param = 7 ; % The teeth surface quelity precision grade

print_flag = 1 ; % pring along the runnig

feature_selection_process_param = load_feature_selection_process_param(...
    num_winds_4_calc_SA_sig) ;

sim_tuning_param = load_simulation_tuning_param() ;

suppress_tf_param = load_suppress_tf_param(use_RMS_normalization, ...
    mitigate_varied_gain_phase) ;

KNN_param = load_KNN_param() ;

% ----------------------------------------------------------------------- %
% Section 4: Load the training and test sets 
% ----------------------------------------------------------------------- %

[training_set, test_set] = load_training_and_test_sets('experimental', ...
    data_path, processed_data_path, num_points_SA_sig, num_winds_4_calc_SA_sig, ...
    rotating_speed, system_load, print_flag) ;

% ----------------------------------------------------------------------- %
% Section 5: Predict the faults sizes using the novel algorithm  
% ----------------------------------------------------------------------- %

[y_prd] = estm_faults_sizes(training_set, test_set, data_path, processed_data_path, ...
    feature_selection_process_param, sim_tuning_param, suppress_tf_param, KNN_param, print_flag) ;

% ----------------------------------------------------------------------- %
% Section 6: Display the results  
% ----------------------------------------------------------------------- %

%%% Prediction error
y_test = test_set.y ;

mae_test = mean(abs(y_prd - y_test)) ;
disp(['Prediction error = ', num2str(100 * mae_test), '%'])

%%% Figure of the predicted y and the real y

ys_lbls = unique(y_test) ;

figure
hold on

for ii = 1 : 1 : length(ys_lbls) 
    
    y_ii_inds = find(y_test == ys_lbls(ii)) ;
    scatter(ys_lbls(ii) * ones(size(y_ii_inds)), y_prd(y_ii_inds), 200, 'filled', 'blue') ;

end

plot(linspace(0, 1, 100), linspace(0, 1, 100), 'LineWidth', 1, 'color', 'black')
hold off

title('Predicted faults sizes VS real sizes')
xlabel('Real fault size')
ylabel('Estimated fault size')

legend({'Predicted'}, 'Location','northwest')


