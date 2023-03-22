function [KNN_param] = load_KNN_param()
% load_KNN_param loads the KNN parameters

KNN_param.Ks = [1 : 1 : 100] ;
KNN_param.normelized = 1 ;

end % of load_KNN_param

