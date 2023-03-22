function [exp_sigs, fualts_sizes] = load_experimental_data(data_path, ...
    processed_data_path, num_points_SA_sig, num_winds_4_calc_SA_sig, ...
    rotating_speed, system_load, print_flag)
% load_experimental_data loads the experimental data

T = (38 / 17) * 1 / rotating_speed ;
num_sigs = 50*floor(60/T) ;
num_cycs = 128 ;

exp_data_path = [data_path, 'experimental signals_load_',num2str(system_load), ...
    '_speed_',num2str(rotating_speed),'\'] ;

exp_sigs = zeros(num_points_SA_sig, num_sigs) ; % pre-allocation
fualts_sizes = zeros(num_sigs, 1) ; % pre-allocation
exp_sigs_before_SA = zeros(num_points_SA_sig * num_cycs, 36) ;
faults_type = zeros(num_sigs, 1) ; % pre-allocation

% the settings of the data
data_settings = [num2str(num_points_SA_sig),'_',num2str(num_winds_4_calc_SA_sig),...
    '_',num2str(rotating_speed), '_', num2str(system_load)] ;

try % if the data with the specific settings was generated before

    load([processed_data_path,'sigs_',num2str(system_load),'_',...
        num2str(rotating_speed),'_',data_settings,'.mat'])
    load([processed_data_path,'fualt_sizes_',num2str(system_load),'_',...
        num2str(rotating_speed),'_',data_settings,'.mat'])

catch

    counter = 1 ;
    exp_sigs_before_SA_counter = 1 ;

    for ii = 1 : 1 : 24

        load([exp_data_path,'signal number ',num2str(ii),'.mat'])

        if print_flag == 1

            disp(['load = ', num2str(sig_properties.load), ', speed = ' , ...
                num2str(sig_properties.speed), ', signal number = ', num2str(ii)])

        end % of if

        num_pnts = num_points_SA_sig * num_winds_4_calc_SA_sig;
        
        if num_points_SA_sig ~= sig_properties.RFs
        
            acc_sig_cyc = resample(acc_sig_cyc, num_points_SA_sig, sig_properties.RFs, 10);
            
        end % of if
        
        num_segments = floor(length(acc_sig_cyc) / num_pnts) ;

        exp_sigs_before_SA(:, exp_sigs_before_SA_counter) = acc_sig_cyc(...
            1 : num_points_SA_sig * num_cycs) ;
        exp_sigs_before_SA_counter = exp_sigs_before_SA_counter + 1 ;

        for mm = 1 : 1 : num_segments

            acc_sig = acc_sig_cyc(((mm-1)*num_pnts+1):(mm*num_pnts)) ;
            [SA_sig, ~] = calc_SA(acc_sig, num_points_SA_sig, 1, num_winds_4_calc_SA_sig) ;
            exp_sigs(:, counter) = SA_sig ;
            fualts_sizes(counter) = sig_properties.y_label ;
            faults_type(counter) = ceil(ii / 6) ;
            counter = counter + 1 ;

        end % of for

        run_time = toc() ;

        if print_flag == 1

            disp(['time = ', num2str(round(run_time)), ', fault size = ', ...
                num2str(sig_properties.y_label)])

        end % of if

    end % of for

    exp_sigs = exp_sigs(:, 1 : (counter-1)) ;
    fualts_sizes = fualts_sizes(1 : (counter-1)) ;

    healthy_inds = find(fualts_sizes == 0) ;
    healthy_sigs = exp_sigs(:, healthy_inds) ;

    save([processed_data_path,'sigs_',num2str(system_load),'_',...
        num2str(rotating_speed),'_',data_settings,'.mat'], 'exp_sigs')
    save([processed_data_path,'fualt_sizes_',num2str(system_load),'_',...
        num2str(rotating_speed),'_',data_settings,'.mat'], 'fualts_sizes')
    save([processed_data_path,'sigs_healthy_',num2str(system_load),'_',...
        num2str(rotating_speed),'_',data_settings,'.mat'], 'healthy_sigs')

end % of try

end % load_experimental_data