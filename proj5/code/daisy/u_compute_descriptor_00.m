%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Written and (C) by                                                      %
% Engin Tola                                                              %
%                                                                         %
% web   : http://cvlab.epfl.ch/~tola/                                     %
% email : engin.tola@epfl.ch                                              %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function desc = u_compute_descriptor_00(dzy, y, x, orientation)
HN = dzy.HN;
HQ = dzy.HQ;

o = floor(orientation);
assert( o >= 0 & o< 360 );

shift  = dzy.ostable(o+1);
ishift = double(floor(shift));

desc(HN,HQ)=single(0);


for h=1:HN
    ci = dzy.ogrid(h,1,o+1);
    yy = floor(y + dzy.ogrid(h,2,o+1));
    xx = floor(x + dzy.ogrid(h,3,o+1));
%    [yy xx]
    if (yy < 0) || yy>(dzy.h-1) || (xx<0) || xx>(dzy.w-1)
        continue;
    end
    hist(:,1) = dzy.H( yy*dzy.w+xx+1, :, ci );
    desc(h,:) = circshift(hist,-ishift);
end
