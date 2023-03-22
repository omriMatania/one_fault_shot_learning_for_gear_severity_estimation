function training_set = simulation_tuning_of_DIN_grade(training_set, test_set, data_path, ...
    processed_data_path, sim_tuning_param, suppress_tf_param, ...
    feature_selection_process_param, KNN_param, print_flag)
% simulation_tuning_of_DIN_grade tunes the DIN grade of the simulated signals for addressing the differences between simulation and experimental data.
% The DIN grade controls the fault to harmonic signal ratio which is mage larger in the simulated data in comparison to the experimental data.

min_err = inf ;

if print_flag
    predicted_fault_sizes = zeros(size(sim_tuning_param.possible_DIN_param)) ;
    disp(' ')
    disp('Step 2: Addressing simulation and experimental data differences by tuning the DIN grade')
end % of if

for ii = 1 : 1 : length(sim_tuning_param.possible_DIN_param)

    target_healthy_sigs = training_set.target_healthy_sigs.x ;
    faulty_exmaple = training_set.faulty_exmaple.x ;

    DIN_grade = sim_tuning_param.possible_DIN_param(ii) ;
    
    if print_flag
        disp(['Current DIN grade = ', num2str(DIN_grade), '/', ...
            num2str(sim_tuning_param.possible_DIN_param(end)), ', t = ', ...
            num2str(round(toc()))])
    end % of if
    
% ----------------------------------------------------------------------- %
% Step 1: Load the training with the designated DIN grade parameter.
% ----------------------------------------------------------------------- %
    
    [sim_sigs, faults_sizes] = load_realistic_dynamic_simulation_sigs(...
        data_path, processed_data_path, training_set.num_points_SA_sig, ...
        training_set.num_winds, training_set.speed, training_set.load, DIN_grade) ;
    training_set.x = sim_sigs; training_set.y = faults_sizes ;
    
% ----------------------------------------------------------------------- %
% Step 2: Load the test set with the training faulty exmple.
% ----------------------------------------------------------------------- %

    test_set.x = training_set.faulty_exmaple.x ;
    test_set.y = training_set.faulty_exmaple.y ;
    
% ----------------------------------------------------------------------- %
% Step 3: Estimation of the transfer function by a healthy signal from the
% target domain using background estimation by ACS and minimum phase estimation.
% ----------------------------------------------------------------------- %

    tf_estm = estm_tf_by_background_and_minimum_phase(...
        training_set.target_healthy_example_long.x, ...
        suppress_tf_param, size(test_set.x, 1)) ;

% ----------------------------------------------------------------------- %
% Step 4: Propagation of the simulated data via the estimated transfer
% function.
% ----------------------------------------------------------------------- %

    tf_estm_mtrx = repmat(tf_estm, 1, size(training_set.x, 2)) ;
    training_set.x = real(ifft(tf_estm_mtrx .* fft(training_set.x))) ;

% ----------------------------------------------------------------------- %
% Step 5: Address the attenuation effects by RMS normaliztion
% ----------------------------------------------------------------------- %

    [training_set, test_set] = RMS_normalization(training_set, test_set) ;

% ----------------------------------------------------------------------- %
% Step 6: Subtraction of the harmonic signal
% ----------------------------------------------------------------------- %

    [training_set, test_set] = substruction_harmonic_sig(processed_data_path, ...
        training_set, test_set) ;

% ----------------------------------------------------------------------- %
% Step 7: Features extraction
% ----------------------------------------------------------------------- %

    [x_training, y_training, x_test] = features_extraction(training_set, test_set, ...
        feature_selection_process_param.selected_features, ...
        feature_selection_process_param.SB_num_4_diff) ;

% ----------------------------------------------------------------------- %
% Step 8: Prediction of the fault size using KNN
% ----------------------------------------------------------------------- %

    [y_prd, ~] = KNN_algorithm(x_training, y_training, x_test, KNN_param) ;
    
% ----------------------------------------------------------------------- %
% Step 9: Find the DIN grade with the minimal prediction error
% ----------------------------------------------------------------------- %

    current_err = mean(abs(y_prd - training_set.faulty_exmaple.y)) ;

    if current_err < min_err

        selected_DIN_grade = DIN_grade ;
        min_err = current_err ;

    end % of if

    training_set.target_healthy_sigs.x = target_healthy_sigs ;
    training_set.faulty_exmaple.x = faulty_exmaple ;
    
    if print_flag
        predicted_fault_sizes(ii) = y_prd ;
    end % of if

end % of for

if print_flag
    display_results(training_set, selected_DIN_grade, sim_tuning_param, ...
        predicted_fault_sizes) ;
end % of if

[sim_sigs, faults_sizes] = load_realistic_dynamic_simulation_sigs(...
    data_path, processed_data_path, training_set.num_points_SA_sig, ...
    training_set.num_winds, training_set.speed, training_set.load, selected_DIN_grade) ;
training_set.x = sim_sigs; training_set.y = faults_sizes ;

end % of simulation_tuning_of_DIN_grade

% ----------------------------------------------------------------------- %

function [] = display_results(training_set, selected_DIN_grade, sim_tuning_param, ...
    predicted_fault_sizes)

figure
plot(sim_tuning_param.possible_DIN_param, predicted_fault_sizes, ...
    'LineWidth', 3, 'color', 'blue')
hold on
plot(sim_tuning_param.possible_DIN_param, ...
    training_set.faulty_exmaple.y * ones(size(sim_tuning_param.possible_DIN_param)), ...
    'LineWidth', 3, 'color', 'black')
hold off

title('Predicted fault size VS DIN grade')
xlabel('DIN grade')
ylabel('Predicted fault size')

xlim([sim_tuning_param.possible_DIN_param(1) sim_tuning_param.possible_DIN_param(end)])
ylim([0 1])

legend({'Predicted size', 'Real size'}, 'Location','northwest')

disp(['The selected DIN grade for tuning the simultion is ', num2str(selected_DIN_grade)])

end % of display_results