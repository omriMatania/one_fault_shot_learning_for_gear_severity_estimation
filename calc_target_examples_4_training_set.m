function [test_sigs, test_faults_sizes, faulty_exmaple_sig, faulty_exmaple_size, ...
        helathy_exp_sigs, healthy_exp_long, fault_ind, start_ind] = ...
        calc_target_examples_4_training_set(data_path, system_load, rotating_speed, ...
        exp_sigs, exp_faults_sizes)
% calc_target_examples_4_training_set moves healthy signals and one faulty
% example of the experimental system to the training set.
    
num_of_records_per_fault = 6 ; num_of_faults_type = 4 ;
    
exp_data_path = [data_path, 'experimental signals_load_', num2str(system_load), ...
    '_speed_',num2str(rotating_speed),'\'] ;
load([exp_data_path,'signal number 6.mat']) ;
healthy_exp_long = acc_sig_cyc ;

healthy_inds = find(exp_faults_sizes == 0) ;    
faults_inds = find(exp_faults_sizes > 0) ;
len_healthy_sigs = length(healthy_inds) ;

healthy_inds = healthy_inds(round(len_healthy_sigs * (1 / 6)) + 1 : end) ;
fault_ind = faults_inds(randi([1, length(faults_inds)])) ;
num_sigs_from_same_record = length(exp_faults_sizes) / ...
    (num_of_records_per_fault * num_of_faults_type) ;
start_ind = num_sigs_from_same_record * floor(fault_ind / num_sigs_from_same_record) + 1 ;
end_ind = num_sigs_from_same_record * ceil(fault_ind / num_sigs_from_same_record) ;
sigs_from_same_record_inds = [start_ind : end_ind].' ;

helathy_exp_sigs = exp_sigs(:, healthy_inds) ;
faulty_exmaple_sig = exp_sigs(:, fault_ind) ;
faulty_exmaple_size = exp_faults_sizes(fault_ind) ;
exp_sigs(:, [healthy_inds; sigs_from_same_record_inds]) = [] ;
exp_faults_sizes([healthy_inds; sigs_from_same_record_inds]) = [] ;

test_sigs = exp_sigs ;
test_faults_sizes = exp_faults_sizes ;

end % of calc_target_examples_4_training_set

