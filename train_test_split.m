function [x_training, x_test, y_training, y_test, training_inds] = ...
    train_test_split(x, y, test_percentage)
% train_test_split splites x and y to train and test sets.
%   [XS_TRAIN, XS_TEST, YS_TRAIN, YS_TEST, training_inds] = TRAIN_TEST_SPLIT(
%   x,y,test_percentage) is a random splitting of x and y to train and 
%   test sets. The size of the test set equals test_percentage from the 
%   size of the original set and the train set (100 - test_percentage). 
%
%   training_inds are the indices of the train set in the original set.
%
%   Example: If x = [1 2; 3 4; 5 6; 7 8; 9 10]; and y = [6, 7, 8, 9, 10];
%   
%   an optional random splitting is: x_training = [1 2; 5 6; 7 8]; x_test = 
%   [3 4; 9 10]; y_training = [6, 8, 9]; y_test = [7, 10]; training_inds = [1, 
%   3, 4];

if test_percentage > 1
    
    test_percentage = test_percentage / 100 ;
    
end % of if

cv = cvpartition(size(x.',1),'HoldOut',test_percentage);
idx = cv.test;

% Separate to training and test data
x_training = x(:,~idx);
x_test  = x(:,idx);

if size(y, 2) > 1
    y_training = y(:,~idx);
    y_test  = y(:,idx);
else
    y_training = y(~idx);
    y_test  = y(idx);
end % of if

training_inds = ~idx ;

end % of train_test_split

