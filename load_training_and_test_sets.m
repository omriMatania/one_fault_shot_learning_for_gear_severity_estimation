function [training_set, test_set] = load_training_and_test_sets(database_type, ...
    data_path, processed_data_path, num_points_SA_sig, num_winds_4_calc_SA_sig, ...
    rotating_speed, system_load, print_flag, DIN_grade)
% load_training_and_test_sets loads the training and test sets

test_set.type = database_type ;
test_set.num_points_SA_sig = num_points_SA_sig ;
test_set.speed = rotating_speed ;
test_set.load = system_load ;
test_set.GM = 38 ;
test_set.num_winds = num_winds_4_calc_SA_sig ;

if nargin < 9

    test_set.DIN_grade = 7 ; % default value
    
else
    
    test_set.DIN_grade = DIN_grade ;

end % of if

training_set = test_set ;

if strcmp(database_type, 'experimental')
    
    [exp_sigs, exp_fualts_sizes] = load_experimental_data(data_path, processed_data_path, ...
        num_points_SA_sig, num_winds_4_calc_SA_sig, rotating_speed, system_load, print_flag) ;
    
    [test_sigs, test_fualts_sizes, faulty_exmaple_sig, faulty_exmaple_size, ...
        helathy_exp_sigs, healthy_exp_long, fault_ind, start_ind] = ...
        calc_target_examples_4_training_set(data_path, system_load, rotating_speed, ...
        exp_sigs, exp_fualts_sizes) ;
    
    test_set.x = test_sigs ;
    test_set.y = test_fualts_sizes ;
    
    training_set.target_healthy_sigs.x = helathy_exp_sigs ;
    training_set.faulty_exmaple.x = faulty_exmaple_sig ;
    training_set.faulty_exmaple.y = faulty_exmaple_size ;
    training_set.target_healthy_example_long.x = healthy_exp_long ;
    training_set.faulty_exmaple.original_ind = fault_ind ;
    training_set.faulty_exmaple.original_record_first_ind = start_ind ;
    training_set.sim_sigs.train_inds = -1 ;
   
elseif strcmp(database_type, 'simulated')
    
    num_rep = 64 ;
    
    [sim_sigs, faults_sizes] = load_realistic_dynamic_simulation_sigs(...
        data_path, processed_data_path, num_points_SA_sig, num_winds_4_calc_SA_sig, ...
        rotating_speed, system_load, DIN_grade) ;
        
    test_inds = [1 : 1 : length(faults_sizes)].' ;
    train_inds = [1 : 1 : length(faults_sizes)].' ;
    
    test_set.test_inds = test_inds ;
    test_set.sim_sigs.train_inds = train_inds ;
    sim_sigs = sim_sigs(:, test_inds) ;
    faults_sizes = faults_sizes(test_inds) ;
    
    tf_num = 1 ;
    tf = load_measured_tf(data_path, tf_num, num_points_SA_sig * num_rep) ;
    
    sigs_test = repmat(sim_sigs, num_rep, 1) ;
    healthy_inds = find(faults_sizes == 0) ;
    rms_healtyh = rms(sigs_test(:, healthy_inds(1))) ;
    
    noise_amp = 0.1 ;
    attenuation = 1 ;
    sigs_test = sigs_test + noise_amp * rms_healtyh * randn(size(sigs_test)) ;
    sigs_test = attenuation * sigs_test ;
    tf_mtrx = repmat(tf, 1, size(sigs_test, 2)) ;
    sigs_test = real(ifft(tf_mtrx .* fft(sigs_test))) ;
    
    sig_healthy_long = sigs_test(:, healthy_inds(1)) ;
    
    sigs_test = calc_SA(sigs_test, num_points_SA_sig, 1, num_winds_4_calc_SA_sig) ;
    
    len_healthy_sigs = length(healthy_inds) ;
    
    healthy_inds = healthy_inds(round(len_healthy_sigs / 2) + 1 : end) ;
    
    helathy_test_sigs = sigs_test(:, healthy_inds) ;
    
    sigs_test(:, healthy_inds) = [] ;
    faults_sizes(healthy_inds) = [] ;
    
    test_set.x = sigs_test ;
    test_set.y = faults_sizes;
    
    training_set.target_healthy_sigs.x = helathy_test_sigs ;
    training_set.target_healthy_example_long.x = sig_healthy_long ;
    
end % of if

end % of load_training_and_test_sets

