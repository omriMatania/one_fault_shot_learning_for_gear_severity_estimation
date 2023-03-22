function tf = load_measured_tf(data_path, tf_num, num_points)
% load_measured_tf loads the measured transfer function number tf_num

load([data_path, 'measured_transfer_functions\H', num2str(tf_num)]) ;
tf = interp_transfer_function(H, num_points) ;
tf = tf / rms(tf) ;

end % of load_measured_tf

