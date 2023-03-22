function [suppress_tf_param] = load_suppress_tf_param(use_RMS_normalization, ...
    mitigate_varied_gain_phase)
% load_estm_tf_param loads the parameters for the estimation of the
% transfer funciton

suppress_tf_param.technique = 'ACS' ;
suppress_tf_param.len_PSD = 2 ^ 15 ;
suppress_tf_param.ACS.segment_size = 200 ;

suppress_tf_param.use_RMS_normalization = use_RMS_normalization ;
suppress_tf_param.mitigate_varied_gain_phase = mitigate_varied_gain_phase ;

end % of load_estm_tf_param

