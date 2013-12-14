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

function cubes = load_cubes(rq,hq)

cubes(:,:,1,1) = load_binary('cube0_layer0.bin');
h = size(cubes,1);
w = size(cubes,2);
cubes(h,w,hq,rq)=0;

for r=1:rq
    for l=1:hq
        cubes(:,:,l,r) = load_binary(strcat('cube',num2str(r-1),'_layer',num2str(l-1),'.bin'));
    end
end
