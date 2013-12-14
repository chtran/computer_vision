%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Written and (C) by                                                      %
% Engin Tola                                                              %
%                                                                         %
% web   : http://cvlab.epfl.ch/~tola/                                     %
% email : engin.tola@epfl.ch                                              %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function gim = rgb_to_gray( im )

if size(im,3) ~= 3
    gim = single(im);
    return;
end

im = single(im);

% assuming im(:,:,1) = red
% assuming im(:,:,2) = green
% assuming im(:,:,3) = blue
gim = 0.299 * im(:,:,1) + 0.587 * im(:,:,2) + 0.114 * im(:,:,3);
