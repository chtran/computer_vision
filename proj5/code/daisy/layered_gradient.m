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
% computes the oriented gradient magnitudes in layer_no layers
%

function [L] = layered_gradient( im, layer_no )

%% first smooth the image 
hf = gaussian_1d(0.5, 0, 5);
im=conv2(im, hf, 'same');
im=conv2(im, hf', 'same');

%% compute x and y derivates
hf = [1 0 -1]/2;
vf = hf';
dx = conv2(im,hf,'same');
dy = conv2(im,vf,'same');

%% compute layers
[h,w]=size(im);
L(h,w,layer_no)=single(0);
for l=0:layer_no-1
    th=2*l*pi/layer_no;
    kos=cos(th);
    zin=sin(th);
    L(:,:,l+1) = max(kos*dx+zin*dy,0);
end
