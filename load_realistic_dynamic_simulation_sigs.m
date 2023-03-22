function [sim_sigs_t, sim_faults_sizes] = load_realistic_dynamic_simulation_sigs(...
    data_path, processed_data_path, num_points_SA_sig, num_winds_4_calc_SA_sig, ...
    rotating_speed, system_load, DIN_grade)
% load_realistic_dynamic_simulation_sigs loads the signals of the realistic dynamic simulation

num_sims = 750 ;

simulations_path = [data_path, 'simulations_load_',num2str(system_load),...
    '_speed_',num2str(rotating_speed),'_DIN_',num2str(DIN_grade),'\'] ;

data_settings = [num2str(num_points_SA_sig),'_',num2str(num_winds_4_calc_SA_sig), ...
    '_',num2str(rotating_speed), '_', num2str(system_load),'_DIN_',num2str(DIN_grade)] ;

try % if the data with the specific settings was generated before

    load([processed_data_path,'sim_sigs_t',data_settings,'.mat'])
    load([processed_data_path,'sim_faults_sizes',data_settings,'.mat'])

catch
    
    load([simulations_path,'simulation number ',num2str(1)]) ;
    load([simulations_path,'simulation number ',num2str(num_sims)]) ;
    
    sim_sigs_t = zeros(num_points_SA_sig, num_sims) ;
    sim_faults_sizes = zeros(num_sims, 1) ;
    
    for sim_num = 1 : 1 : num_sims
        
        load([simulations_path,'simulation number ',num2str(sim_num)]) ;
        
        SA_sig = simulation_results.SA_sig ;
        SA_sig = interp1(linspace(0,1,length(SA_sig)), SA_sig, ...
            linspace(0,1,num_points_SA_sig)) ;
        sim_sigs_t(:, sim_num) = SA_sig ;
        
        sim_faults_sizes(sim_num) = calc_fault_width(simulation_properties, 1) ;
        
    end % of for
    
    save([processed_data_path,'sim_sigs_t',data_settings,'.mat'], 'sim_sigs_t')
    save([processed_data_path,'sim_faults_sizes',data_settings,'.mat'], 'sim_faults_sizes')
    
end % of try

end %  of load_realistic_dynamic_simulation_sigs

