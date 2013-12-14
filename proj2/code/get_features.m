% Local Feature Stencil Code
% CS 143 Computater Vision, Brown U.
% Written by James Hays

% Returns a set of feature descriptors for a given set of interest points. 

% 'image' can be grayscale or color, your choice.
% 'x' and 'y' are nx1 vectors of x and y coordinates of interest points.
%   The local features should be centered at x and y.
% 'feature_width', in pixels, is the local feature width. You can assume
%   that feature_width will be a multiple of 4 (i.e. every cell of your
%   local SIFT-like feature will have an integer width and height).
% If you want to detect and describe features at multiple scales or
% particular orientations you can add input arguments.

% 'features' is the array of computed features. It should have the
%   following size: [length(x) x feature dimensionality] (e.g. 128 for
%   standard SIFT)

function [features] = get_features(image, x, y, feature_width)

% To start with, you might want to simply use normalized patches as your
% local feature. This is very simple to code and works OK. However, to get
% full credit you will need to implement the more effective SIFT descriptor
% (See Szeliski 4.1.2 or the original publications at
% http://www.cs.ubc.ca/~lowe/keypoints/)

% Your implementation does not need to exactly match the SIFT reference.
% Here are the key properties your (baseline) descriptor should have:
%  (1) a 4x4 grid of cells, each feature_width/4.
%  (2) each cell should have a histogram of the local distribution of
%    gradients in 8 orientations. Appending these histograms together will
%    give you 4x4 x 8 = 128 dimensions.
%  (3) Each feature should be normalized to unit length
%
% You do not need to perform the interpolation in which each gradient
% measurement contributes to multiple orientation bins in multiple cells
% As described in Szeliski, a single gradient measurement creates a
% weighted contribution to the 4 nearest cells and the 2 nearest
% orientation bins within each cell, for 8 total contributions. This type
% of interpolation probably will help, though.

% You do not have to explicitly compute the gradient orientation at each
% pixel (although you are free to do so). You can instead filter with
% oriented filters (e.g. a filter that responds to edges with a specific
% orientation). All of your SIFT-like feature can be constructed entirely
% from filtering fairly quickly in this way.

% You do not need to do the normalize -> threshold -> normalize again
% operation as detailed in Szeliski and the SIFT paper. It can help, though.

% Another simple trick which can help is to raise each element of the final
% feature vector to some power that is less than one.

num_points = size(x,1);
features = zeros(num_points, 128);

small_gaussian = fspecial('Gaussian', [feature_width feature_width], 1);
large_gaussian = fspecial('Gaussian', [feature_width feature_width], feature_width/2);

[gx, gy] = imgradientxy(small_gaussian);
ix = imfilter(image, gx);
iy = imfilter(image, gy);

get_octant = @(x,y) (ceil(atan2(y,x)/(pi/4)) + 4);
%figure;
%hold on
%colormap(gray)
%axis equal;
%axis off;
%set(gca,'YDir','reverse')
%imagesc(image);

%title('Key point frames');
orients = arrayfun(get_octant, ix, iy);
mag = hypot(ix, iy);
c_size = feature_width/4;
for ii = 1:num_points
    frame_x_range = (x(ii) - 2*c_size): (x(ii) + 2*c_size-1);
    frame_y_range = (y(ii) - 2*c_size): (y(ii) + 2*c_size-1);
    %rectangle('Position', [x(ii) - 2*c_size, y(ii) - 2*c_size, feature_width, feature_width], 'EdgeColor', 'Red');
    frame_mag = mag(frame_y_range, frame_x_range);
    frame_mag = frame_mag.*large_gaussian;
    frame_orients = orients(frame_y_range, frame_x_range);
    % Looping through each cell in the frame
    for xx = 0:3
        for yy = 0:3
            cell_orients = frame_orients(xx*4+1:xx*4+4, yy*4+1:yy*4+4);
            cell_mag = frame_mag(xx*4+1:xx*4+4, yy*4+1:yy*4+4);
            for o = 1:8
                f = cell_orients == o;
                features(ii, (xx*32 + yy*8) + o) = sum(sum(cell_mag(f)));
            end
        end
    end
end
features = diag(1./sum(features,2))*features; %Normalize feature vectors
    
end








