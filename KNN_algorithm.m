function [y_prd, selected_K] = KNN_algorithm(x_training, y_training, x_test, ...
    KNN_param)
% KNN_algorithm predicts y for x_test using the K nearest neighbors of x_training.

if size(y_training, 2) == 1
    y_training = y_training .' ;
    rotate_returned_vctr = 1 ;
else
    rotate_returned_vctr = 0 ;
end % of if

test_percentage = 0.3 ;

try
   
    if KNN_param.normelized == 1
       
        x_sigmas = std(x_training.').' ;
        x_training = x_training ./ repmat(x_sigmas, 1, size(x_training, 2)) ;
        x_test = x_test ./ repmat(x_sigmas, 1, size(x_test, 2)) ;
        
    end % of if
     
catch 
    
end % of try

[x_training_4_val, x_val, y_training_4_val, y_val, train_inds] = ...
    train_test_split(x_training, y_training, test_percentage) ;

min_err = inf ;
err_as_function_K = zeros(size(KNN_param.Ks)) ;

for ii = 1 : 1 : length(KNN_param.Ks) 
    
    K = KNN_param.Ks(ii) ;
    x_inds = knnsearch(x_training_4_val.', x_val.', 'K', K) ;
    y_prd = y_training_4_val(x_inds.') ;
    y_prd = mean(y_prd, 1) ;
    
    current_err = mean(abs(y_val - y_prd)) ;
    err_as_function_K(ii) = current_err ;
    
    if current_err < min_err
    
        selected_K = K ;
        min_err = current_err ;
        
    end % of if
    
end % of for

x_inds = knnsearch(x_training.', x_test.', 'K', selected_K) ;
y_prd = y_training(x_inds.') ;

if size(y_prd, 1) == size(x_test, 2)
    
    y_prd = mean(y_prd, 2) ;
    
else
   
    y_prd = mean(y_prd, 1) ;
    
end % of if

if rotate_returned_vctr == 1 
    y_prd = y_prd .' ;
end % of if

end % of KNN_algorithm

