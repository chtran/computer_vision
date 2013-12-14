%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Written and (C) by                                                      %
% Engin Tola                                                              %
%                                                                         %
% web   : http://cvlab.epfl.ch/~tola/                                     %
% email : engin.tola@epfl.ch                                              %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% smooth all the layers with sigma
%

function [SL] = smooth_layers( L, sigma )

fsz = filter_size(sigma);

hf = gaussian_1d(sigma, 0, fsz);

ln = size(L,3);

for l=1:ln
    SL(:,:,l) = conv2(L(:,:,l),hf,'same');
    SL(:,:,l) = conv2(SL(:,:,l),hf','same');
    
%     figure(29)
%     imagesc(SL(:,:,l))
%     pause
end
