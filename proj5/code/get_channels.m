function channels = get_channels(img)
%'img' is height x width x 3 (RGB)
%'channels' is height x width x 14, with the 14 channels specified in
%sketch tokens Section 2.2.1

% helpful functions: I = rgbConvert(I,'luv') and imfilter
height = size(img, 1);
width = size(img, 2);
channels = zeros(height, width, 14);
channels(:,:,1:3) = rgbConvert(img, 'luv');

gray_img = rgb2gray(img);
mag_sigmas = [0, 1.5, 5];
for ii=1:3
    if mag_sigmas(ii)>0
        gaussian = fspecial('Gaussian', [5 5], mag_sigmas(ii));
    else
        gaussian = zeros(5,5);
        gaussian(3,3)=1;
    end
    [gx, gy] = imgradientxy(gaussian);

    ix = imfilter(gray_img, gx, 'symmetric');
    iy = imfilter(gray_img, gy, 'symmetric');
    channels(:, :, ii+3) = hypot(ix,iy);
    if(ii<3)
        angles = [0, pi/4, pi/2, 3*pi/4];
        for jj=1:4
            angle = angles(jj);
            channels(:,:, 6+(ii-1)*4+jj) = hypot(ix.*cos(angle), iy.*sin(angle));
        end
    end
end
end
