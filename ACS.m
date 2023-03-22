function [bs_estm] = ACS(sgns_PSD, sgmnt_size, options)
%{
ACS (Adaptive Clatter Separation) estimates the spectrum
background using selection process of a percentage value for each
segment. The technique filters out extreme deviations from the
background corresponded to the picks.
The function supports matrix calculations.
=====
Inputs:
sgns_PSD - PSD of the signals. The input must contain positive real values.
options can contain:
    options.OLP - over-lapping percentage between consecutive segments.
    options.selcted_percentage - percentage to select in every segment.
    options.sgmnt_size - segment size.
    options.interp_type - interpolation type.
=====
Outputs:
bs_estm - estimated backgrounds.
=====
function's variables:
num_OL_celles - number of over-lapping cells.

This code which implimentes ACS can be used for any academic porpuse, but 
however, if you use the code or just part of it you must cite this two papers:
[1] Matania O, Klein R, Bortman J. "Novel approaches for the estimation of
    the spectrum background for stationary and quasi-stationary signals." 
    Mech Syst Signal Process 2022;167. https://doi.org/10.1016/j.ymssp.2021.108503."
[2] Matania O, Klein R, Bortman J. "Algorithms for spectrum background
    estimation of non-stationary signals." Mech Syst Signal Process 2022;167.
    https://doi.org/10.1016/j.ymssp.2021.108551
%}
% ----------------------------------------------------------------------- %

%%% Part 1: preliminaries
bs_estm = zeros(size(sgns_PSD));
len_PSD = size(sgns_PSD, 1) ;
num_sgns = size(sgns_PSD, 2) ;

options.create = '';
[selected_percentage, OLP, interp_type] = set_default_values(options) ;

for sgn_num = 1 : 1 : num_sgns
    
    sgn_PSD = sgns_PSD(:, sgn_num);
    
    num_OL_celles = floor(sgmnt_size * (OLP / 100));

    len_percent_value_vctr = floor((len_PSD + 1 - sgmnt_size) / (sgmnt_size - num_OL_celles));
    percent_value_matrix = zeros(sgmnt_size, len_percent_value_vctr);
    %%% Part 2: 
    for ii = 1 : 1 : len_percent_value_vctr
        percent_value_matrix(:,ii) = sgn_PSD(1 + (sgmnt_size-num_OL_celles)*(ii-1):...
            sgmnt_size + (sgmnt_size - num_OL_celles)*(ii-1))';
    end % of for

    percent_value_vctr = prctile(percent_value_matrix,selected_percentage,1);
    %%% Part 3: interpolation
    xq = 1 : 1 : len_PSD;
    x1 = (sgmnt_size + 1) / 2;
    x = x1 : sgmnt_size-num_OL_celles : x1 + (len_percent_value_vctr - 1) * ...
        (sgmnt_size - num_OL_celles) ;
    if length(percent_value_vctr) > 1
        b_estm = interp1(x, percent_value_vctr, xq, interp_type, percent_value_vctr(1)).' ;
    elseif length(percent_value_vctr) == 1
        b_estm = percent_value_vctr*ones(len_PSD, 1);
    else
        error('percent_value_vctr is an empty matrix')
    end % of if

    b_estm = rectify_2b_symmetrical(b_estm);
    
    bs_estm(:, sgn_num) = b_estm;
end % of for

end % of ACS

% ----------------------------------------------------------------------- %

function [selected_percentage, OLP, interp_type] = set_default_values(options)

try
    selected_percentage = options.selected_percentage;
catch
    selected_percentage = 50;
end % of try

try
    OLP = options.OLP;
catch
    OLP = 75;
end % of try

try
    interp_type = options.interp_type;
catch
    interp_type = 'pchip';
end % of try

end % of set_default_values