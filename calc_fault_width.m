function [fault_width] = calc_fault_width(simulation_properties, normalized)
% calc_fault_width calculates the tooth's fault width under the assumption it is a full tooth face fault (FTFF).

if nargin < 2
    
    normalized = 0 ; % if to calculate the fault width in mm (0) or normalized where 0 is healthy, 1 is a missing tooth (1)

end % of if

try
    
	x_fault_start = simulation_properties.defect_info_g.coordinates.def_start.x ;
    y_fault_start = simulation_properties.defect_info_g.coordinates.def_start.y ;
    
    x_fault_end = simulation_properties.defect_info_g.coordinates.def_end.x ;
    y_fault_end = simulation_properties.defect_info_g.coordinates.def_end.y ;
    
    w_def = sqrt((x_fault_end-x_fault_start)^2+(y_fault_end-y_fault_start)^2) ;
    
    fault_width = w_def ;

catch
    
    fault_width = 0 ;

end % of try

if normalized && fault_width > 0
    
    x_init_cont = simulation_properties.defect_info_g.coordinates.init_cont.x ;
    y_init_cont = simulation_properties.defect_info_g.coordinates.init_cont.y ;
    
    x_invlt_end = simulation_properties.defect_info_g.coordinates.invlt_end.x ;
    y_invlt_end = simulation_properties.defect_info_g.coordinates.invlt_end.y ;
    
    width_invlt = sqrt((x_invlt_end-x_init_cont)^2+(y_invlt_end-y_init_cont)^2) ; % involute's width
    
    fault_width = fault_width / width_invlt ; 
    
end % of if

end % of calc_fault_width

