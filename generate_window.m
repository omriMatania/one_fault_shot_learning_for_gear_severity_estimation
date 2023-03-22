function windows = generate_window(mtrx_size, wind_type, wind_len, options)
%{
% DESCRIPTION:
% This function generates windows as set by "mtrx_size". The
% number of columns equal to the number of windows, and the total signal 
% length (not to be confused with the window length "wind_len") equal to the
% length of every column. All the windows are identical. the type of the windows is
% "wind_type". The windows have the length "wind_length" and they are padded
% with zeros to achieve the total signal length designated by "mtrx_aize(1)".
% =====
% INPUTS:
% mtrx_size = [total signal length, num_sngs] - the window size.
% wind_type - The window type (expect string). can be 'hann' for hanning or 
% 'rect' for rectangular.
% wind_len - The window length.
% options - contains:
%     options.using_GPU - 1 for using GPU.
% =====
% OUTPUTS:
% windows - The windows:
% ||...|
% ||...|
% ||...|
% ww...w
% ii...i
% nn...n
% dd...d
% oo...o
% ww...w
% 12...n
% ||...|
% ||...|
% ||...|
% =====
% IN-FUNCTION VARIABLES:
% len_sgn - length of every column. Need to be correspond to the length of
% every signal.
% num_sngs - number of signals.
%}
% ----------------------------------------------------------------------- %

%%% Part 1 - preliminaries:
len_sgn = mtrx_size(1); num_sngs = mtrx_size(2);

%%% Part 2 - generate the window accroding to the specified type:
if strcmp(wind_type, 'hann')

    if wind_len == 0

        window = zeros(len_sgn, 1);

    else

        window = hann(round(2 * wind_len + 1));
        up_wind = window(round(wind_len + 1) : end - 1);
        down_wind = flipud(up_wind(2 : wind_len));
        mid_wind = zeros(len_sgn - length(up_wind) - length(down_wind), 1);
        window = [up_wind; mid_wind; down_wind];

        if length(window) > len_sgn
            window = window(1 : len_sgn);
            window = rectify_2b_symmetrical( window );
        end % of if

    end % of if

elseif strcmp(wind_type,'rect')

    if wind_len == 0

        window = zeros(len_sgn, 1);

    else

        up_wind = ones(ceil(wind_len), 1);
        down_wind = ones(floor(wind_len) - 1, 1);
        mid_wind = zeros(len_sgn - length(up_wind) - length(down_wind), 1);
        window = [up_wind; mid_wind; down_wind];

        if length(window) > len_sgn
            window = window(1 : len_sgn);
        end % of if

    end % of if
end % of if

%%% Part 3 - repeat the vector "num_sngs" times:
try options.using_GPU
    windows = gpuArray(window) * gpuArray(ones(1, num_sngs));
catch
    windows = repmat(window, 1, num_sngs);
end % of try

end % of generate_window