%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Written and (C) by                                                      %
% Engin Tola                                                              %
%                                                                         %
% web   : http://cvlab.epfl.ch/~tola/                                     %
% email : engin.tola@epfl.ch                                              %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function dsc=compute_descriptor(dzy, y, x, ori, spatial_int, hist_int, nt)

if spatial_int==1 && hist_int == 1
    dsc = u_compute_descriptor_11(dzy,y,x,ori);
elseif spatial_int==0 && hist_int == 1
    dsc = u_compute_descriptor_01(dzy,y,x,ori);
elseif spatial_int==1 && hist_int == 0
    dsc = u_compute_descriptor_10(dzy,y,x,ori);
else
    dsc = u_compute_descriptor_00(dzy,y,x,ori);
end

if nt == 0
    return;
elseif nt == 1
    dsc = normalize_partial(dsc);
elseif nt == 2
    dsc = normalize_full(dsc);
elseif nt == 3
    dsc = normalize_sift(dsc);
end

