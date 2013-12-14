function output = my_imfilter(image, filter)
% This function is intended to behave like the built in function imfilter()
% See 'help imfilter' or 'help conv2'. While terms like "filtering" and
% "convolution" might be used interchangeably, and they are indeed nearly
% the same thing, there is a difference:
% from 'help filter2'
%    2-D correlation is related to 2-D convolution by a 180 degree rotation
%    of the filter matrix.

% Your function should work for color images. Simply filter each color
% channel independently.

% Your function should work for filters of any width and height
% combination, as long as the width and height are odd (e.g. 1, 7, 9). This
% restriction makes it unambigious which pixel in the filter is the center
% pixel.

% Boundary handling can be tricky. The filter can't be centered on pixels
% at the image boundary without parts of the filter being out of bounds. If
% you look at 'help conv2' and 'help imfilter' you see that they have
% several options to deal with boundaries. You should simply recreate the
% default behavior of imfilter -- pad the input image with zeros, and
% return a filtered image which matches the input resolution. A better
% approach is to mirror the image content over the boundaries for padding.

% % Uncomment if you want to simply call imfilter so you can see the desired
% % behavior. When you write your actual solution, you can't use imfilter,
% % filter2, conv2, etc. Simply loop over all the pixels and do the actual
% % computation. It might be slow.
% output = imfilter(image, filter);


%%%%%%%%%%%%%%%%
% Your code here
%%%%%%%%%%%%%%%%

function one_channel_output = one_channel_filter(image, filter)    
    img_height = size(image, 1);
    img_width = size(image, 2);
    filter_height = size(filter, 1);
    filter_width = size(filter, 2);
    pad_height = (filter_height - 1)/2; % size of vertical padding
    pad_width = (filter_width - 1)/2; % size of horizontal padding

    one_channel_output = zeros(img_height, img_width); % pre-allocate output matrix
    padded = zeros(img_height + 2 * pad_height, img_width + 2 * pad_width); % pre-allocate padded matrix
    padded(1 + pad_height: img_height + pad_height, 1 + pad_width: img_width + pad_width) = image; % copy the input image over
    for ii = 1 : img_height
        for jj = 1 : img_width
            submatrix = padded(ii : ii + 2 * pad_height, jj : jj + 2 * pad_width); % get the submatrix surrounding this pixel      
            one_channel_output(ii, jj) = sum(sum(submatrix .* filter));
        end
    end
end

output = zeros(size(image));
dim = length(size(image)); %1 if gray scale, 3 if colored
if (dim == 1)
    output = one_channel_filter(image, filter);
elseif (dim == 3)
    for d = 1: 3
        output(:, :, d) = one_channel_filter(image(:, :, d), filter);
    end
end
end


