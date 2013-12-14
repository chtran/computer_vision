%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Written and (C) by                                                      %
% Engin Tola                                                              %
%                                                                         %
% web   : http://cvlab.epfl.ch/~tola/                                     %
% email : engin.tola@epfl.ch                                              %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function desc = u_compute_descriptor_10(dzy, y, x, orientation)

HN = dzy.HN;
HQ = dzy.HQ;

o = floor(orientation);
assert( o >= 0 & o< 360 );

shift  = dzy.ostable(o+1);
ishift = double(floor(shift));

desc(HN,HQ)=single(0);

for h=1:HN
    ci = dzy.ogrid(h,1,o+1);
    yy = y + dzy.ogrid(h,2,o+1);
    xx = x + dzy.ogrid(h,3,o+1);
    iy=floor(yy);
    ix=floor(xx);

    b = yy-iy;
    a = xx-ix;

    if (iy < 0) || iy>(dzy.h-2) || (ix<0) || ix>(dzy.w-2)
        continue;
    end

    % A C
    % B D
    ha(:,1) = dzy.H( iy    *dzy.w+ix+1, :, ci );
    hb(:,1) = dzy.H( (1+iy)*dzy.w+ix+1, :, ci );
    hc(:,1) = dzy.H( iy    *dzy.w+ix+2, :, ci );
    hd(:,1) = dzy.H( (1+iy)*dzy.w+ix+2, :, ci );

    hist = (1-b)*(a*hc+(1-a)*ha)+b*(a*hd+(1-a)*hb);

    desc(h,:) = circshift(hist,-ishift);
end

