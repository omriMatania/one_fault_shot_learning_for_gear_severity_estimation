function selected_features = feature_selection_process(training_set, ...
    data_path, processed_data_path, feature_selection_process_param, suppress_tf_param, ...
    print_flag)
%{
feature_selection_process selects the features that are invariant to the 
unmitigated effects of the transfer function. Be aware that the errors between
the training and test sets is not identical in every run of the algorithm, and
thus also does not equal to the results that are presented in the article, as
the errors depends on the signal operating conditions and on randomness in the
generation of the simulated signals. However, for all the checked cases the 
kurtosis_env_diff and skewness_env_diff have very large error and diff_RMS and
RMS_env_diff have low error.
%}

if print_flag
    disp('Step 1: Feature selection process')
end % of if
    
% ----------------------------------------------------------------------- %
% Step 1: Generate the test set by propagating the simulated signals via a
% measured transfer funciton.
% ----------------------------------------------------------------------- %

[training_set, test_set] = load_training_and_test_sets('simulated', ...
    data_path, processed_data_path, training_set.num_points_SA_sig, training_set.num_winds, ...
    training_set.speed, training_set.load, print_flag, training_set.DIN_grade) ;

% ----------------------------------------------------------------------- %
% Step 2: Estimation of the transfer function by a healthy signal from the
% target domain using background estimation by ACS and minimum phase estimation.
% ----------------------------------------------------------------------- %

tf_estm = estm_tf_by_background_and_minimum_phase(training_set.target_healthy_example_long.x, ...
    suppress_tf_param, size(test_set.x, 1)) ;

% ----------------------------------------------------------------------- %
% Step 3: Propagation of the simulated data via the estimated transfer
% function for generating the training set.
% ----------------------------------------------------------------------- %

[sim_sigs, faults_sizes] = load_realistic_dynamic_simulation_sigs(...
        data_path, processed_data_path, training_set.num_points_SA_sig, training_set.num_winds, ...
        training_set.speed, training_set.load, training_set.DIN_grade) ;
training_set.x = sim_sigs; training_set.y = faults_sizes ;

tf_estm_mtrx = repmat(tf_estm, 1, size(training_set.x, 2)) ;
training_set.x = real(ifft(tf_estm_mtrx .* fft(training_set.x))) ;

% ----------------------------------------------------------------------- %
% Step 4: Address the attenuation effects by RMS normaliztion
% ----------------------------------------------------------------------- %

[training_set, test_set] = RMS_normalization(training_set, test_set) ;

% ----------------------------------------------------------------------- %
% Step 5: Subtraction of the harmonic signal
% ----------------------------------------------------------------------- %

[training_set, test_set] = substruction_harmonic_sig(processed_data_path, ...
    training_set, test_set) ;

% ----------------------------------------------------------------------- %
% Step 6: Features extraction
% ----------------------------------------------------------------------- %

[x_training, ~, x_test] = features_extraction(training_set, test_set, ...
    feature_selection_process_param.features_names, ...
    feature_selection_process_param.SB_num_4_diff) ;

x_training = x_training(:, 1 : size(x_test, 2));

% ----------------------------------------------------------------------- %
% Step 7: Calculation of the errors between the distributions of the
% extracted features of the training and test sets.
% ----------------------------------------------------------------------- %

selected_features = {} ;
errors = [] ;
counter = 1 ;

if print_flag
    figure
    figures_letters = {'(a)', '(b)', '(c)', '(d)'} ;
    full_features_names = {'RMS of the differnce signal', ...
        'Kurtosis of the envelope of the difference signal', ...
        'RMS of the envelope of the difference signal', ...
        'Skewness of the envelope of the difference signal'} ;
end % of if

for feature_num = 1 : 1 : size(x_training, 1)
   
    x_sigma = min([std(x_training(feature_num, :)), std(x_test(feature_num, :))]) ;
    feature_error = mean(abs(x_training(feature_num, :) - x_test(feature_num, :)) / x_sigma) ;
    errors = [errors, feature_error] ;
    
    if feature_error < (feature_selection_process_param.err_thresold_4_selection / 100)       
        
        selected_features{counter} = ...
            feature_selection_process_param.features_names{feature_num} ;
        
        counter = counter + 1 ;
        
    end % of if
    
    if print_flag
        
        subplot(2, 2, feature_num)
        scatter(x_training(feature_num, :), test_set.y, 100, 'filled')
        hold on
        scatter(x_test(feature_num, :), test_set.y, 100, 'filled')
        hold off
        
        title([figures_letters{feature_num}, ' ',full_features_names{feature_num}])
        xlabel('Feature value')
        ylabel('Fault size')
        
        legend({'Training', 'Test'}, 'Location','northwest')

    end % of if
    
end % of for

if print_flag

    display_results(feature_selection_process_param, errors, selected_features)
    
end % of if

end % of feature_selection_process

% ----------------------------------------------------------------------- %

function [] = display_results(feature_selection_process_param, errors, selected_features)

for_printing = [] ;

for ii = 1 : 1 : 2
    
    for_printing = [for_printing, feature_selection_process_param.features_names{ii}, ...
        ': ', num2str(errors(ii) * 100), '% '] ;
    
end % of for

disp(for_printing)
for_printing = [] ;

for ii = 1 : 1 : 2
    
    for_printing = [for_printing, feature_selection_process_param.features_names{ii + 2}, ...
        ': ', num2str(errors(ii + 2) * 100), '% '] ;
    
end % of for

disp(for_printing)

disp('Selected features: ')
for ii = 1 : 1 : length(selected_features)
    disp(selected_features{ii})
end % of for

end % of display_results