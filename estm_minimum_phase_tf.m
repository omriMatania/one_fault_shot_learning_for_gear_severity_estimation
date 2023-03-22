function [tf] = estm_minimum_phase_tf(tf_gain)
% estm_minimum_phase_tf estimates the minimum phase of the transfer function and returns the transfer function, gain and phase as a complex numbers, in the frequency domain.

len_tf = length(tf_gain) ;
end_ind_up = ceil((len_tf - 1)/ 2);
end_ind_down = floor((len_tf - 1) / 2) + 1;

%%% convert to the cepstrum domain
tf_complex_cepst = ifft(log10(tf_gain));

%%% set to zero the negative quefrencies and double the positive quefrencies 
tf_complex_cepst = [tf_complex_cepst(1); 2 * tf_complex_cepst(2 : end_ind_up); ...
    zeros(end_ind_down, 1)];

%%% convert back to the frequency domain
tf = 10 .^ (fft(tf_complex_cepst));

end % of estm_minimum_phase_tf