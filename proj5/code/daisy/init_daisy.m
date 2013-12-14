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
% This code is a matlab implementation of the algorithm presented in the
% paper titled 'A Fast Local Descriptor for Dense Matching' by Engin Tola,
% Vincent Lepetit and Pascal Fua published in the proceedings of the
% Computer Vision and Pattern Recognition 2008 Conference.
%
% Please give a reference to that paper if you use this code in any
% academic work.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Source code is available under the GNU General Public License. In short,
% if you distribute a software that uses DAISY, you have to distribute it
% under GPL with the source code. Another option is to contact us to
% purchase a commercial license.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% See the usage.matlab document about the details on how to use this code
% and some warnings
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [dzy] = init_daisy(image, R, RQ, TQ, HQ, SI, LI, NT)

%%
if nargin == 5
    SI = 1;
    LI = 1;
    NT = 1;
elseif nargin == 1
    R  = 15;
    RQ = 3;
    TQ = 8;
    HQ = 8;
    SI = 1;
    LI = 1;
    NT = 0;
end

%% init grid points and sigma's to use for cubes
% fprintf(1,'-------------------------------------------------------\n');
% fprintf(1,'0. init grid+sigmas;\n');
grid = compute_grid(R,RQ,TQ);
ogrid = compute_oriented_grid(grid,360);

[cind, csigma] = compute_level_sigmas(R,RQ,TQ);
cn = length(cind); % number of cubes -> might be different
                   % than RQ in future releases

%% compute layers
if size(image,3)~=1
    im = rgb_to_gray(image);
else
    im = single(image);
end
if(max(max(im))>1)
    im = im/255.0;
end
% im = load_binary('input.bin');

%%% layers
% fprintf(1,'1. compute layers ');
% tic;
L = layered_gradient(im,HQ);

% %%% smooth them to sigma 1.6 assuming they have .5 in the beginning
% sig_inc=sqrt(1.6^2-0.5^2);
% L = smooth_layers(L,sig_inc);
% % time_cl=toc;
% % fprintf(1,'is done in %f sec\n',time_cl);

%% compute cubes
% tic;
% fprintf(1,'2. compute cubes: ');

for r=1:cn
%     fprintf(1,strcat(num2str(r),'..'));
    % we do incremental smoothing...
    if r==1
        sigma=csigma(r);
        dzy.CL(:,:,:,r) = smooth_layers(L,sigma);
    else
        sigma=sqrt( csigma(r)^2 - csigma(r-1)^2 );
        dzy.CL(:,:,:,r) = smooth_layers(dzy.CL(:,:,:,r-1), sigma);
    end
end
% time_cc = toc;
% fprintf(1,' is done in %f secs\n',time_cc);

%% compute histograms
h = size(im,1);
w = size(im,2);
for r=1:cn
    dzy.TCL(:,:,:,r) = transpose_cube(dzy.CL(:,:,:,r));
    dzy.H(:,:,r) = reshape( dzy.TCL(:,:,:,r), h*w, HQ );
end
dzy.CL = [];
dzy.TCL = [];

%%
dzy.h  = size(im,1);
dzy.w  = size(im,2);
dzy.R  = R;
dzy.RQ = RQ;
dzy.TQ = TQ;
dzy.HQ = HQ;
dzy.HN      = size(grid,1);
dzy.DS      = dzy.HN*HQ;
dzy.grid    = grid;
dzy.ogrid   = ogrid;
dzy.cind    = cind;
dzy.csigma  = csigma;
dzy.ostable = compute_orientation_shift(HQ,1);
% fprintf(1,'-------------------------------------------------------\n');
dzy.SI = SI;
dzy.LI = LI;
dzy.NT = NT;
dzy.params = single([dzy.DS dzy.HN dzy.h dzy.w R RQ TQ HQ SI LI NT length(dzy.ostable)]);
% fprintf(1,'precomputation total time: %f sec\n',time_cl+time_cc);

%% Auxilary Functions

% computes the grid points from descriptor parameters.
function grid=compute_grid(R,RQ,TQ)

rs=R/RQ;
ts=2*pi/TQ;

gs = RQ*TQ+1;

grid(gs,3)=single(0);

grid(1,1:3)=[1 0 0];
cnt=1;
for r=0:RQ-1
    for t=0:TQ-1
        cnt=cnt+1;

        rv = (r+1)*rs;
        tv = t*ts;
        grid(cnt,1)=r+1;
        grid(cnt,2)=rv*sin(tv); % y
        grid(cnt,3)=rv*cos(tv); % x
    end
end

% rotate the grid

function ogrid = compute_oriented_grid(grid,GOR)

GN = size(grid,1);

ogrid( GN, 3, GOR )=single(0);

for i=0:GOR-1

    th = -i*2.0*pi/GOR;

    kos = cos( th );
    zin = sin( th );

    for k=1:GN

        y = grid(k,2);
        x = grid(k,3);

        ogrid(k,1,i+1) = grid(k,1);
        ogrid(k,2,i+1) = -x*zin+y*kos;
        ogrid(k,3,i+1) = x*kos+y*zin;
    end
end


% computes the required shift for each orientation
function ostable=compute_orientation_shift(hq,res)
if nargin==1
    res=1;
end
ostable = single(0:res:359)*hq/360;
return;

%
function tc = transpose_cube( cube )
[h, w, n]=size(cube);
tc(w,h,n)=single(0);
for i=1:n
    tc(:,:,i) = transpose(cube(:,:,i));
end

%
function [cind,csigma] = compute_level_sigmas(R,RQ,TQ)
csigma(RQ)=0;
rs = R/RQ;
for r=0:RQ-1
    cind(r+1)=r+1;
    csigma(r+1)=(r+1)*rs/2;
end
