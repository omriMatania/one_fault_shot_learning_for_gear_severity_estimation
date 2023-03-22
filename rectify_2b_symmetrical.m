function [symmetrical_background] = rectify_2b_symmetrical(background)
% rectify_2b_symmetrical rectifies the background to be symmetrical

len_b = length(background);

if mod(len_b, 2) == 0
    
	symmetrical_background = [background(1 : len_b / 2 + 1) ; flipud(background(2 : len_b / 2 ))];
	
else

    symmetrical_background = [background(1 : round(len_b / 2)) ; flipud(background(2 : round(len_b / 2)))];

end % of if

end % of rectify_2b_symmetrical