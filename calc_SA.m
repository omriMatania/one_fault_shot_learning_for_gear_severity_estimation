function [SA_sigs, cycle_SA, num_of_winds_2_average] = calc_SA(sigs, num_of_points_of_cycle, num_of_cycs, num_of_winds_2_average)
% calc_SA calculates the synchronous average (SA) of the signals

wind_size = num_of_points_of_cycle * num_of_cycs ; % wind stands for window 

if nargin == 3
    
    num_of_winds_2_average = floor(size(sigs, 1) / wind_size) ;
    
end % of if


if num_of_winds_2_average * wind_size > length(sigs)
    
    num_of_winds_2_average = floor(size(sigs, 1) / wind_size) ;

end % of if

sigs = sigs(1 : num_of_winds_2_average * wind_size, :) ;

if size(sigs, 2) > 1

    all_winds = reshape(sigs, wind_size, num_of_winds_2_average, size(sigs, 2)) ;
    
else
    
    all_winds = reshape(sigs, wind_size, num_of_winds_2_average) ;
    
end % of if

SA_sigs = mean(all_winds, 2) ;

if size(sigs, 2) > 1

    SA_sigs = squeeze(SA_sigs) ;
    
end % of if

cycle_SA = 0 : (1 / num_of_points_of_cycle) : (num_of_cycs - (1 / num_of_points_of_cycle)) ; % cycle axis

end % of calc_SA