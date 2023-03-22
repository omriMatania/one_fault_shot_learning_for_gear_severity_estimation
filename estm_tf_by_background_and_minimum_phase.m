function tf_estm = estm_tf_by_background_and_minimum_phase(sig_t, suppress_tf_param, tf_len)
% estm_tf_by_background_and_minimum_phase estimates the transfer function by background estimation using ACS and minimum phase 

if nargin < 3 
    tf_len = length(sig_t) ;
end % of if

sig_PSD = calc_PSD(sig_t, suppress_tf_param.len_PSD) ;

background_ACS = ACS(sig_PSD, suppress_tf_param.ACS.segment_size) ;

tf_estm = estm_minimum_phase_tf(background_ACS) ;

tf_estm = interp_transfer_function(tf_estm(1 : round(length(tf_estm) / 2) + 1), tf_len) ; % interpolation of the transfer function to its original size

end % of estm_tf_by_background_and_minimum_phase

