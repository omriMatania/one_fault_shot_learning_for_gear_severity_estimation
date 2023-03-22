function [x_training, y_training, x_test, y_test] = ...
    features_extraction(training_set, test_set, features_names, side_bands_num_4_diff_calc)
% features_extraction extracts the features from the training and test sets.
% side_bands_num_4_diff_calc is the number of side bands that are subtracted for the calculation of the difference signal 

features_2_extract = convert_names_2_numbers(features_names) ;

x_sim = SA_feature_extraction(training_set.x, training_set.GM, side_bands_num_4_diff_calc, ...
    features_2_extract) ;

if ~isempty(training_set.target_healthy_sigs.x)

    x_target_healthy_training = SA_feature_extraction(training_set.target_healthy_sigs.x, ...
        training_set.GM, side_bands_num_4_diff_calc, features_2_extract) ;

else

    x_target_healthy_training = [] ;
    
end % of if

healthy_sim_inds = find(training_set.y == 0) ;
x_sim = x_sim - repmat(mean(x_sim(:, healthy_sim_inds), 2), 1, size(x_sim, 2)) ;
x_target_healthy_training_new = x_target_healthy_training - ...
    repmat(mean(x_target_healthy_training, 2), 1, size(x_target_healthy_training, 2)) ;

x_training = [x_sim, x_target_healthy_training_new] ;
y_training = [training_set.y; zeros(size(x_target_healthy_training, 2), 1)] ;

x_test = SA_feature_extraction(test_set.x, test_set.GM, side_bands_num_4_diff_calc, features_2_extract) ;
x_test = x_test - repmat(mean(x_target_healthy_training, 2), 1, size(x_test, 2)) ;
y_test = test_set.y ;

end % of features_extraction

% ----------------------------------------------------------------------- %

function [extracted_features] = ...
    SA_feature_extraction(SA_sigs, GM, side_bands_num_4_diff_calc, features_2_extract)
% SA_feature_extraction extractes the features from the synchronous average (SA) signal

difference_sigs = orders_spectrum_filtering(SA_sigs, GM, side_bands_num_4_diff_calc,[]) ;

env_difference_sigs = calc_envelope_by_Hilbert_transfrom(difference_sigs) ;
env_difference_sigs = env_difference_sigs - ...
    repmat(mean(env_difference_sigs, 1), size(env_difference_sigs, 1), 1) ;

rms_diff = [] ;
kur_diff = [] ;
rms_env_diff = [] ;
skew_env_diff = [] ;

intensity = rms(difference_sigs, 1) ; 
zeros_inds = find(intensity < 10 ^ (-10)) ;

if features_2_extract(1) == 1
    
    rms_diff = rms(difference_sigs, 1) ;
    
end % of if

if features_2_extract(2) == 1
    
    kur_diff = kurtosis(difference_sigs) ;
    kur_diff(zeros_inds) = zeros(size(zeros_inds)) ;
    
end % of if

if features_2_extract(3) == 1
    
    rms_env_diff = rms(env_difference_sigs) ;
    
end % of if

if features_2_extract(4) == 1

    skew_env_diff = skewness(env_difference_sigs) ;
    skew_env_diff(zeros_inds) = zeros(size(zeros_inds)) ;
    
end % of if

extracted_features = [rms_diff; kur_diff; rms_env_diff; skew_env_diff] ;

end % of SA_feature_extraction

% ----------------------------------------------------------------------- %

function filtered_signal = orders_spectrum_filtering(SA_sig,GM,side_bands_num_4_diff_calc,particular_ord)
%%% sel_ord_filt
% Nullifies Gear Mesh orders for extruction the Residual & Difference signals. 
% INPUTS:
% SA_sig: Synchronous Average Signal - Has to be in the cycle domain.
% GM: The Gear Mesh - scalar, (number of teeth in case of gear wheel).
% The GM and all of its harmonics will be nullified.
% side_bands_num_4_diff_calc: number of SideBands to nullify - scalar. for example, side_bands_num_4_diff_calc = 2,
% 2 first side_bands_num_4_diff_calc of each side of the GM harmonics will be erased.
% particular_ord: Vector of Orders to erase. Negative Orders will be handled 
% as part of the function.
% OUTPUT:
% filtered_signal is the new signal in the cycle domain.
% WARNING: x mast be 1 cycle(!) In order to obtain resolution of 1[Order].
% Written by NIV KOREN 25/03/2016
%%% 
%%% Step 1 - Initializaion %%
Fs = length(SA_sig) ;
[L,axis_num] = size(SA_sig);

if L < axis_num %% logical check
    SA_sig = SA_sig.';
    [L,~] = size(SA_sig);
end % of if

ord_Vec = [0:floor((L-1)/2)].*(Fs/L) ; % order vector
res = ord_Vec(2) - ord_Vec(1) ; % resolution in the order domain

%%% Step 2 - GM & side_bands_num_4_diff_calc Elimination %%
side_bands_num_4_diff_calc_vec = 1 : side_bands_num_4_diff_calc ; % mostly for the difference signal

if GM
    
	GM_max = floor(ord_Vec(end)/GM) ; % the number of GM harmonics within the bandwidth
    GM_harm_index = [1:GM_max].*GM/res +1 ; % the indexes of GM harmonics 

    for n = 1 : GM_max % the indexes of the side_bands_num_4_diff_calc's (mostly for the difference)
        
		side_bands_num_4_diff_calc_up_ind(1+side_bands_num_4_diff_calc*(n-1):n*side_bands_num_4_diff_calc) =  GM_harm_index(n)+side_bands_num_4_diff_calc_vec/res;
        side_bands_num_4_diff_calc_down_ind(1+side_bands_num_4_diff_calc*(n-1):n*side_bands_num_4_diff_calc) =  GM_harm_index(n)-side_bands_num_4_diff_calc_vec/res;
		
    end % of for
    
    ORD2delet_pos = sort([GM_harm_index' ; side_bands_num_4_diff_calc_down_ind' ; side_bands_num_4_diff_calc_up_ind']) ; % all the indexes to eliminate
    ORD2delet_pos = ORD2delet_pos(ORD2delet_pos < ((L-1)/2)) ; % within the bandwidth 
    ORD2delet_pos = ORD2delet_pos(ORD2delet_pos > 0); % only positive indexes
    ORD2delet_neg = L + 2 - ORD2delet_pos ; % ask renata
    ORD2delet = [ORD2delet_pos ; ORD2delet_neg ] ; 
    ORD2delet = sort(ORD2delet) ;
	
else

    ORD2delet = [] ;
	
end % of if

%%% Step 3 - Particular Orders Elimination %%
if ~isempty(particular_ord)
    particular_ord_ind = particular_ord ;
    
    if max(particular_ord_ind) > ord_Vec(end) || min(particular_ord_ind) < 0
        error('particular_ord doesn''t in the right field');
    end
    
    particular_ord_ind = particular_ord_ind(particular_ord_ind < ((L-1)/2)) ;
    particular_ord_ind = particular_ord_ind(particular_ord_ind >= 0) ;
    particularORD2del_pos = sort(particular_ord_ind)./res + 1 ;
    particularORD2del_neg =  L + 2 - particularORD2del_pos ;
    particularORD2del = [particularORD2del_neg';particularORD2del_pos'] ;
    particularORD2del = sort(particularORD2del);
else
    particularORD2del = [] ;
end % of if

%%% Step 4 - Elimination in the Order domain and ifft %%

X = fft(SA_sig, L, 1) ;
X(ORD2delet, :) = zeros(length(ORD2delet), size(X, 2))  ;
X(particularORD2del) = zeros(length(particularORD2del), size(X, 2)) ;
filtered_signal = ifft(X, L, 1) ;

end % of orders_spectrum_filtering

% ----------------------------------------------------------------------- %
function features_2_extract = convert_names_2_numbers(features_names)

features_2_extract = [0; 0; 0; 0] ;

if any(strcmp(features_names, 'diff_RMS'))
    
    features_2_extract(1) = 1 ;
    
end % of if

if any(strcmp(features_names, 'kurtosis_env_diff'))
    
    features_2_extract(2) = 1 ;
    
end % of if

if any(strcmp(features_names, 'RMS_env_diff'))

    features_2_extract(3) = 1 ;
    
end % of if

if any(strcmp(features_names, 'skewness_env_diff'))
    
    features_2_extract(4) = 1 ;
    
end % of if

end % of convert_names_2_numbers

% ----------------------------------------------------------------------- %

function [envelope_sig_abs, envelope_sig_phase] = calc_envelope_by_Hilbert_transfrom(x)
% calc_envelope_by_Hilbert_transfrom calculates the envelope signal of x using Hilbert transform

[l,ax_num] = size(x);

if l < ax_num
    x = x.';
end % of if

h = hilbert(x);
envelope_sig_abs = abs(h);
envelope_sig_phase = atan2(imag(h),real(h));

end % of calc_envelope_by_Hilbert_transfrom
