function [training_set, test_set] = substruction_harmonic_sig(processed_data_path, ...
    training_set, test_set)
% substruction_harmonic_sig subtracts the harmonic signal

%%% for training set
[training_set.x] = substruction_harmonic_sig_4_simulated_sigs(...
    training_set.x, training_set.y) ;

%%% for test set

if strcmp(test_set.type, 'experimental')
   
    num_of_sigs_per_record = size(training_set.target_healthy_sigs.x, 2) / 5 ;
    
    varible_name = [processed_data_path,'sigs_',num2str(test_set.load),'_', ...
        num2str(test_set.speed),'_',num2str(test_set.DIN_grade), ...
        '_original_fault_ind_',num2str(training_set.faulty_exmaple.original_ind) ...
        ,'_num_test_sigs_',num2str(size(test_set.x, 2)),'_tran_cancel_harmonic_signal.mat'] ;
    
    try
    
        load(varible_name)
    
    catch
        
        delays_ups_num_pnts = 100 ;
        exp_sigs_tran = substruction_harmonic_sig_4_exsperimental_sigs([test_set.x, ...
            training_set.target_healthy_sigs.x(:, 1 : 4 * num_of_sigs_per_record)], ...
            training_set.target_healthy_sigs.x(:, 4 * num_of_sigs_per_record + 1 : end), ...
            delays_ups_num_pnts) ;
        
        save(varible_name, 'exp_sigs_tran')

    end % of try
    
    test_set.x = exp_sigs_tran(:, 1 : end - 4 * num_of_sigs_per_record) ;
    training_set.target_healthy_sigs.x = exp_sigs_tran(:, end - ...
        4 * num_of_sigs_per_record + 1 : end) ;
    
elseif strcmp(test_set.type, 'simulated')
    
    sigs = [test_set.x, training_set.target_healthy_sigs.x] ;
    faults_sizes = [ones(size(test_set.x, 2), 1) ; ...
        zeros(size(training_set.target_healthy_sigs.x, 2), 1)] ;
    
    sigs_subtracted = substruction_harmonic_sig_4_simulated_sigs(sigs, faults_sizes) ;
    
    test_set.x = sigs_subtracted(:, 1 : size(test_set.x, 2)) ;
    training_set.target_healthy_sigs.x = sigs_subtracted(:, ...
        size(test_set.x, 2) + 1 : end) ;
    
end % of if

end % of substruction_harmonic_sig

% ----------------------------------------------------------------------- %

function [sigs] = substruction_harmonic_sig_4_simulated_sigs(sigs, faults_sizes)
% substruction_harmonic_sig_4_simulated_sigs subtracts the harmonic signal for the simulated signals

healthy_inds = find(faults_sizes == 0) ;
healthy_sigs = sigs(:, healthy_inds) ;
sigs = sigs - repmat(healthy_sigs(:, 1), 1, size(sigs, 2)) ;

end % of substruction_harmonic_sig_4_simulated_sigs

% ----------------------------------------------------------------------- %

function [subtructed_sigs] = substruction_harmonic_sig_4_exsperimental_sigs(sigs, ...
    sigs_healthy, delays_ups_num_pnts)
% substruction_harmonic_sig_4_exsperimental_sigs subtracts the harmonic signal for the experimental signals
% For each signal, the function founds the healthy signal and its corresponding delay which minimize the MSE between the signals and healthy signal

sigs_healthy_f = fft(sigs_healthy) ;
subtructed_sigs = zeros(size(sigs)) ;

for sig_num = 1 : 1 : size(sigs, 2)
    
    sig = sigs(:, sig_num) ;
    sig_f = repmat(fft(sig), 1, size(sigs_healthy_f, 2));
    [sigs_delays, estm_delays] = delays_step(sig_f, sigs_healthy_f, delays_ups_num_pnts) ;
    [~, min_ind] = min(rms(sigs_delays - sigs_healthy_f)) ;
    
    subtructed_sig_f = sigs_delays(:, min_ind) - sigs_healthy_f(:, min_ind) ;
    subtructed_sig = real(ifft(calc_x_delays(subtructed_sig_f, ...
        -estm_delays(min_ind), delays_ups_num_pnts))) ;
    
    subtructed_sigs(:, sig_num) = subtructed_sig ;
    
end % of for

end % of substruction_harmonic_sig_4_exsperimental_sigs

% ----------------------------------------------------------------------- %

function [xs_delays, estm_delays] = delays_step(xs_f, ys_f, delays_ups_num_pnts)
%DELAYS_STEP    ESTM_DELAYS corresponding to minimum MSE
%   [XS_DELAYS, ESTM_DELAYS] = DELAYS_STEP(XS_F, YS_F) is a greedy delays 
%   step claculting the ESTM_DELAYS corresponding to minimum MSE between 
%   XS_F and YS_F.
%
%   DELAYS_UPS_NUM_PNTS specifies the up sampling number op points in the
%   delay step process.

%   Copyright 2021 Omri Matania.

size_x = size(xs_f) ;
N = size_x(1) ;
M = size_x(2) ; % number of examples.

if nargin < 3
    
    delays_ups_num_pnts = 1 ;

end % of if

estm_delays = zeros(M, 1) ;

xs_f = Nyquist_interp(xs_f, N * delays_ups_num_pnts, 'frequency') ;
ys_f = Nyquist_interp(ys_f, N * delays_ups_num_pnts, 'frequency') ;

for m = 1 : 1 : M
    
    mse_as_function_of_d = - real(ifft(xs_f(:, m) .* conj(ys_f(:, m)))) ;
    [~, d_estm] = min(mse_as_function_of_d) ;
    d_estm = d_estm - 1 ;
    estm_delays(m) = d_estm ;
    
end % of for

xs_delays = calc_x_delays(xs_f, estm_delays) ;

xs_t = ifft(xs_delays) ;
xs_t = xs_t([1 : delays_ups_num_pnts : N * delays_ups_num_pnts], :) ; 

xs_delays = fft(xs_t) ;

end % of delays_step

% ----------------------------------------------------------------------- %

function [xs_interp] = Nyquist_interp(xs, new_num_pnts, domain)
%Nyquist_interp   Nyquist interpolation of XS. 
%   S = Nyquist_interp(XS, NEW_NUM_PNTS) interpolates XS to contain 
%   NEW_NUM_PNTS by Nyquist theorem.
%   
%   Nyquist_interp(XS, NEW_NUM_PNTS, DOMAIN) gets as input and outs as 
%   output XS and XS_INTERP in the domain DOMAIN.
%
%   Nyquist_interp(XS, NEW_NUM_PNTS, DOMAIN) specifies the domain of XS 
%   and XS_INTERP. Available options are:
%
%   'frequency' - XS and XS_INTERP are presented in the frequency domain. 
%   'time'      - XS and XS_INTERP are presented in the time domain.

%   Copyright 2021 Omri Matania.

if nargin < 3
    
    domain = 'time' ;
    
end % of if

size_x = size(xs) ;
N = size_x(1) ;
M = size_x(2) ;

if strcmp(domain, 'time')

    xs_f = fft(xs) ;
    
elseif strcmp(domain, 'frequency')
    
    xs_f = xs ;

end % of if

if new_num_pnts == N 
    
    xs_interp_f = xs_f ;
    
elseif mod(N, 2) == 0
    
    xs_interp_f = (new_num_pnts / N) * [xs_f(1 : N / 2, :) ; 0.5 * xs_f(N / 2 + 1, :) ; ...
        zeros(new_num_pnts - N - 1, M) ; 0.5 * conj(xs_f(N / 2 + 1, :)) ; ...
        xs_f(N / 2 + 2 : end, :)] ;

elseif mod(N, 2) == 1
    
    xs_interp_f = (new_num_pnts / N) * [xs_f(1 : floor(N / 2) + 1, :) ; ...
        zeros(new_num_pnts - N, M) ; xs_f(floor(N / 2) + 2 : end, :)] ;
    
end % of if

if strcmp(domain, 'time')

    xs_interp = real(ifft(xs_interp_f)) ;

elseif strcmp(domain, 'frequency')
    
    xs_interp = xs_interp_f ;

end % of if

end % of Nyquist_interp

% ----------------------------------------------------------------------- %

function [xs_AD] = calc_x_delays(xs_f, delays, num_pnts)
%CALC_X_DELAYS   XS_F after DELAYS 
%   XS_AD = CALC_X_DELAYS(XS_F,DELAYS) is XS_F after the DELAYS.


size_x = size(xs_f) ;
N = size_x(1) ; % number of samples.
M = size_x(2) ; % number of exsamples.

if nargin < 3
   
    num_pnts = 1 ; 

end % of if

if num_pnts > 1

    delays_mtrx = repmat(delays.', N * num_pnts, 1) ;
    num_mtrx = repmat([0 : 1 : (N * num_pnts) - 1].' / (N * num_pnts), 1, M) ;

    xs_f_old = xs_f ;
    xs_f = zeros(N * num_pnts, M) ;

    for m = 1 : 1 : M

        x_f = xs_f_old(:, m) ;
        x_t = ifft(x_f) ;

        x_t = Nyquist_interp(x_t, N * num_pnts) ;

        xs_f(:, m) = fft(x_t) ;

    end % of for

    xs_AD = xs_f .* exp(2 * pi * 1i * delays_mtrx .* num_mtrx) ;

    xs_AD_old = xs_AD ;
    xs_AD = zeros(N, M) ;

    for m = 1 : 1 : M

        x_f = xs_AD_old(:, m) ;
        x_t = ifft(x_f) ;

        x_t = x_t([1 : num_pnts : N * num_pnts]) ;

        xs_AD(:, m) = fft(x_t) ;

    end % of for
    
else

    delays_mtrx = repmat(delays.', N, 1) ;
    num_mtrx = repmat([0 : 1 : N - 1].' / N, 1, M) ;

    xs_AD = xs_f .* exp(2 * pi * 1i * delays_mtrx .* num_mtrx) ;
	
end % of if

end % of calc_x_delays
