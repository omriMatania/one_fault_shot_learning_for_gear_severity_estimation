function [transfer_function_new] = interp_transfer_function(transfer_function_old, len_new)
% interp_transfer_function interpolates the transfer function from its old length to the new designated length len_new

try 
    interp_type ;
catch
    interp_type = 'spline' ;
end % of try

transfer_function_old = [transfer_function_old(1 : end, :); ...
    conj(flipud(transfer_function_old(2 : end, :)))];

len_old = length(transfer_function_old);
transfer_function_new_abs = interp1(linspace(0, 1, len_old).', abs(transfer_function_old), ...
    linspace(0, 1, len_new).', interp_type);

end_ind_up = ceil((len_new - 1)/ 2) + 1;
end_ind_down = floor((len_new - 1) / 2) + 1;
transfer_function_new_abs = [transfer_function_new_abs(1 : end_ind_up); ...
    conj(flipud(transfer_function_new_abs(2 : end_ind_down)))];

len_old = length(transfer_function_old);
transfer_function_new_angle = interp1(linspace(0, 1, len_old).', unwrap(angle(transfer_function_old)), ...
    linspace(0, 1, len_new).', interp_type);

end_ind_up = ceil((len_new - 1)/ 2) + 1;
end_ind_down = floor((len_new - 1) / 2) + 1;
transfer_function_new_angle = [transfer_function_new_angle(1 : end_ind_up); ...
    conj(flipud(transfer_function_new_angle(2 : end_ind_down)))];

transfer_function_new = transfer_function_new_abs .* exp(1i * transfer_function_new_angle) ;

transfer_function_new = [transfer_function_new(1 : end_ind_up); ...
    conj(flipud(transfer_function_new(2 : end_ind_down)))];

end % of interp_transfer_function