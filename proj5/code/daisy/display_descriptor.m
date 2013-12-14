%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Written and (C) by                                                      %
% Engin Tola                                                              %
%                                                                         %
% web   : http://cvlab.epfl.ch/~tola/                                     %
% email : engin.tola@epfl.ch                                              %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out=display_descriptor(dzy, y, x)

% if y<0 || x<0 || y>dzy.h-1 || x>dzy.w-1
%     error('index out of bounds');
% end
%     
% out = reshape( dzy.descs( y*dzy.w+x+1, :), dzy.HQ, dzy.HN )';

if y<1 || x<1 || y>dzy.h || x>dzy.w
    error('index out of bounds');
end
    
out = reshape( dzy.descs( (y-1)*dzy.w+x, :), dzy.HQ, dzy.HN );
