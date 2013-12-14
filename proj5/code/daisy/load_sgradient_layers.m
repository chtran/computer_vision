%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Written and (C) by                                                      %
% Engin Tola                                                              %
%                                                                         %
% web   : http://cvlab.epfl.ch/~tola/                                     %
% email : engin.tola@epfl.ch                                              %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function GL = load_sgradient_layers(hq)

for l=1:hq
    GL(:,:,l) = load_binary(strcat('sgradient_layers',num2str(l-1),'.bin'));
end

