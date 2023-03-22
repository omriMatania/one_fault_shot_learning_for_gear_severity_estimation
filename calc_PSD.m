function [sgns_PSD] = calc_PSD(sgns_t, len_PSD, options)
% calc_PSD calculates the PSD of sgns_t, it returns a vector with size of len_PSD
% Inputs:
%   sgns_t - the signals in the time domain
%   len_PSD - the length of the calculated PSD
% Outputs:
%   sgns_PSD - the calculated PSD of sgns_t.
% ----------------------------------------------------------------------- %

try
    wind_type = options.window.wind_type; % wind stands for window
catch
    wind_type = 'rect';
end % of try

try
    pow_degree = options.pow_degree;
catch
    pow_degree = 2;
end % of try

%%% pre-allocation
sgns_PSD = zeros(len_PSD, size(sgns_t, 2));
num_sgns = size(sgns_t, 2);

%%% generation of the window
wind_size = [len_PSD, num_sgns];
window = generate_window(wind_size, wind_type, round(len_PSD / 2 + 1));

for ii = 1:floor(size(sgns_t, 1) / len_PSD)
    sgns_PSD = sgns_PSD + abs(fft(sgns_t((ii-1) * len_PSD + 1 : ii * len_PSD, :)...
        .*window)) .^ pow_degree;
end % of for

if pow_degree == 1
   sgns_PSD = (sgns_PSD / (floor(size(sgns_t, 1) / len_PSD) * size(sgns_PSD, 1)));
else
   sgns_PSD = (sgns_PSD / (floor(size(sgns_t, 1) / len_PSD)*size(sgns_PSD,1)))...
       .^(1/pow_degree); 
end % of if

end % of calc_PSD