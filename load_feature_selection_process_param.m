function [feature_selection_process_param] = load_feature_selection_process_param(...
    num_winds_4_calc_SA_sig)
% load_features_extruction_param loads the parameters of the feature selection process. 

num_of_side_bands_4_diff_calc = 2 ; % number of side bands to be subtracted for calculating the difference signal

feature_selection_process_param.features_names = {'diff_RMS', 'kurtosis_env_diff', ...
    'RMS_env_diff', 'skewness_env_diff'} ;
feature_selection_process_param.err_thresold_4_selection = 10 ; % in percent (%)
feature_selection_process_param.tf_num = 1 ;
feature_selection_process_param.noise_amp = 0.1 ;
feature_selection_process_param.attenuation = 1 ;
feature_selection_process_param.num_winds_4_calc_SA_sig = num_winds_4_calc_SA_sig ;
feature_selection_process_param.SB_num_4_diff = num_of_side_bands_4_diff_calc ;

end % of load_features_extruction_param

