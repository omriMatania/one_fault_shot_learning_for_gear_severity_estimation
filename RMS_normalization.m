function [training_set, test_set] = RMS_normalization(training_set, test_set)
% RMS_normalization normalizes the RMS of the signals using the RMS of the healthy signals.

rms_target_health_training = mean(rms(training_set.target_healthy_sigs.x)) ;

test_set.x = test_set.x / rms_target_health_training ;
training_set.target_healthy_sigs.x = training_set.target_healthy_sigs.x / ...
    rms_target_health_training ;
	
try
    training_set.faulty_exmaple.x = training_set.faulty_exmaple.x / ...
        rms_target_health_training ;
catch
    
end % of try

healthy_inds = find(training_set.y == 0) ;
rms_healthy_sim = mean(rms(training_set.x(:, healthy_inds))) ;
training_set.x = training_set.x / rms_healthy_sim ;

end % of RMS_normalization