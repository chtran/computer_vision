




% Local Feature Stencil Code
% CS 143 Computater Vision, Brown U.
% Written by James Hays

% Returns a set of interest points for the input image

% 'image' can be grayscale or color, your choice.
% 'feature_width', in pixels, is the local feature width. It might be
%   useful in this function in order to (a) suppress boundary interest
%   points (where a feature wouldn't fit entirely in the image, anyway)
%   or(b) scale the image filters being used. Or you can ignore it.

% 'x' and 'y' are nx1 vectors of x and y coordinates of interest points.
% 'confidence' is an nx1 vector indicating the strength of the interest
%   point. You might use this later or not.
% 'scale' and 'orientation' are nx1 vectors indicating the scale and
%   orientation of each interest point. These are OPTIONAL. By default you
%   do not need to make scale and orientation invariant local features.
function [x, y, confidence, scale, orientation] = get_interest_points(image, feature_width)

% Implement the Harris corner detector (See Szeliski 4.1.1) to start with.
% You can create additional interest point detector functions (e.g. MSER)
% for extra credit.

% If you're finding spurious interest point detections near the boundaries,
% it is safe to simply suppress the gradients / corners near the edges of
% the image.

% The lecture slides and textbook are a bit vague on how to do the
% non-maximum suppression once you've thresholded the cornerness score.
% You are free to experiment. Here are some helpful functions:
%  BWLABEL and the newer BWCONNCOMP will find connected components in 
% thresholded binary image. You could, for instance, take the maximum value
% within each component.
%  COLFILT can be used to run a max() operator on each sliding window. You
% could use this to ensure that every interest point is at a local maximum
% of cornerness.
alpha=0.05;
gaussian = fspecial('Gaussian', [25 25], 1);
[gx, gy] = imgradientxy(gaussian);
ix = imfilter(image, gx);
iy = imfilter(image, gy);
large_gaussian = fspecial('Gaussian', [25 25], 10);
ixx = imfilter(ix.*ix, large_gaussian);
ixy = imfilter(ix.*iy, large_gaussian);
iyy = imfilter(iy.*iy, large_gaussian);
har = ixx.*iyy - ixy.*ixy - alpha.*(ixx+iyy).*(ixx+iyy);

threshold = 0.01;
thresholded = har > threshold;
components = bwconncomp(thresholded);
width = components.ImageSize(1);
height = components.ImageSize(2);

return_values = zeros(components.NumObjects, 3);
for ii=1:(components.NumObjects)
    pixel_ids = components.PixelIdxList{ii};
    pixel_values = har(pixel_ids);
    [max_value, max_id] = max(pixel_values);
    return_values(ii, 1) = floor(pixel_ids(max_id)/ width);
    return_values(ii, 2) = mod(pixel_ids(max_id), width);
    return_values(ii, 3) = max_value;
end
    
chosen_rows = (return_values(:,1) > feature_width/2 & ...
    return_values(:,1) < height - feature_width/2 & ...
    return_values(:,2) > feature_width/2 & ...
    return_values(:,2) < width - feature_width/2);
return_values = return_values(chosen_rows, :);
x = return_values(:,1);
y = return_values(:,2);
confidence = return_values(:,3);

end