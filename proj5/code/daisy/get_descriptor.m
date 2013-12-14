%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Written and (C) by                                                      %
% Engin Tola                                                              %
%                                                                         %
% web   : http://cvlab.epfl.ch/~tola/                                     %
% email : engin.tola@epfl.ch                                              %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%'get_descriptor' is a modification of 'display_descriptor' by James Hays.
%There are several issues with display descriptor:
% (1) The name implies visualization.
% (2) The coordinates are indexed [0 width-1] instead of [1 width]
% (3) The descriptor block is transposed, which makes the correspondence
% between the raw block of descriptors in dzy.descs and the individual
% descriptors returned by display_descriptor confusing. It's easy to cause
% a bug if you, for instance, sample training features with
% display_descriptor but then apply a classifier to every row of dzy.descs
% at test time. With this function, that is safe to do.

function out=get_descriptor(dzy, y, x)

if y<1 || x<1 || y>dzy.h || x>dzy.w
    error('index out of bounds');
end
    
out = reshape( dzy.descs( (y-1)*dzy.w+x, :), dzy.HQ, dzy.HN );
