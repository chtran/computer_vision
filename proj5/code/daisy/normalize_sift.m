%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Written and (C) by                                                      %
% Engin Tola                                                              %
%                                                                         %
% web   : http://cvlab.epfl.ch/~tola/                                     %
% email : engin.tola@epfl.ch                                              %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function dsc = normalize_sift(udsc)

threshold = 0.154;
changed = 1;
iter = 0;
max_iter = 5;

dsc = udsc;
while( changed && iter < max_iter )
    iter=iter+1;
    changed = 0;

    dsc=normalize_full(dsc);

    if sum(sum(dsc> threshold)) > 0
        dsc(dsc>threshold) = threshold;
        changed=1;
    end
end
