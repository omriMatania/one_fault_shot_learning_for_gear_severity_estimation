function [y_prd] = ...
    estm_faults_sizes(training_set, test_set, data_path, processed_data_path, ...
    feature_selection_process_param, sim_tuning_param, suppress_tf_param, KNN_param, print_flag)
%{
estm_faults_sizes estimates the fault sizes of the test set by one-fault-shot
learning. The function implements the ideas of the novel algorithm that was
suggested in the paper "". Follow figure ??? to see the exact steps of the
algorithm.
%}

% ----------------------------------------------------------------------- %
% Step 1: Feature selection process
% ----------------------------------------------------------------------- %

selected_features = feature_selection_process(training_set, data_path, ...
    processed_data_path, feature_selection_process_param, suppress_tf_param, print_flag) ;
feature_selection_process_param.selected_features = selected_features ;

% ----------------------------------------------------------------------- %
% Step 2: Addressing the diffrences between simulation and experimntal data
% by tuning the DIN grade of the simulated signals
% ----------------------------------------------------------------------- %
training_set = simulation_tuning_of_DIN_grade(training_set, test_set, data_path, ...
    processed_data_path, sim_tuning_param, suppress_tf_param, ...
    feature_selection_process_param, KNN_param, print_flag) ;

% ----------------------------------------------------------------------- %
% Step 3: Estimation of the transfer function by a healthy signal from the
% target domain using background estimation by ACS and minimum phase estimation.
% ----------------------------------------------------------------------- %
if suppress_tf_param.mitigate_varied_gain_phase
    
    if print_flag
        disp(' ')
        disp('Step 3: Estimation of the transfer function by ACS and minimum phase estimation')
    end % of if

    tf_estm = estm_tf_by_background_and_minimum_phase(...
        training_set.target_healthy_example_long.x, suppress_tf_param, size(test_set.x, 1)) ;

% ----------------------------------------------------------------------- %
% Step 4: Propagation of the simulated data via the estimated transfer
% function.
% ----------------------------------------------------------------------- %

    if print_flag
        disp(' ')
        disp('Step 4: Propagation of the simulated data via the estimated transfer function')
    end % of if

    tf_estm_mtrx = repmat(tf_estm, 1, size(training_set.x, 2)) ;
    training_set.x = real(ifft(tf_estm_mtrx .* fft(training_set.x))) ;

end % of if

% ----------------------------------------------------------------------- %
% Step 5: Address the attenuation effects by RMS normaliztion
% ----------------------------------------------------------------------- %

if suppress_tf_param.use_RMS_normalization

    if print_flag
        disp(' ')
        disp('Step 5: Address the attenuation effects by RMS normaliztion')
    end % of if

    [training_set, test_set] = RMS_normalization(training_set, test_set) ;

end % of if

% ----------------------------------------------------------------------- %
% Step 6: Subtraction of the harmonic signal
% ----------------------------------------------------------------------- %

if print_flag
    disp(' ')
    disp('Step 6: Subtraction of the harmonic signal')
end % of if

[training_set, test_set] = substruction_harmonic_sig(processed_data_path, ...
    training_set, test_set) ;

% ----------------------------------------------------------------------- %
% Step 7: Features extraction
% ----------------------------------------------------------------------- %

if print_flag
    disp(' ')
    disp('Step 7: Features extraction')
end % of if

[x_training, y_training, x_test] = features_extraction(training_set, test_set, ...
    feature_selection_process_param.selected_features, ...
    feature_selection_process_param.SB_num_4_diff) ;

% ----------------------------------------------------------------------- %
% Step 8: Prediction of the fault size using KNN
% ----------------------------------------------------------------------- %

if print_flag
    disp(' ')
    disp('Step 8+9: Feature pre-processing and KNN')
end % of if

[y_prd, ~] = KNN_algorithm(x_training, y_training, x_test, KNN_param) ;

end % estm_faults_sizes

