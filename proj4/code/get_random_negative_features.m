% Starter code prepared by James Hays for CS 143, Brown University
% This function should return negative training examples (non-faces) from
% any images in 'non_face_scn_path'. Images should be converted to
% grayscale, because the positive training data is only available in
% grayscale. For best performance, you should sample random negative
% examples at multiple scales.

function features_neg = get_random_negative_features(non_face_scn_path, feature_params, num_samples)
% 'non_face_scn_path' is a string. This directory contains many images
%   which have no faces in them.
% 'feature_params' is a struct, with fields
%   feature_params.template_size (probably 36), the number of pixels
%      spanned by each train / test template and
%   feature_params.hog_cell_size (default 6), the number of pixels in each
%      HoG cell. template size should be evenly divisible by hog_cell_size.
%      Smaller HoG cell sizes tend to work better, but they make things
%      slower because the feature dimensionality increases and more
%      importantly the step size of the classifier decreases at test time.
% 'num_samples' is the number of random negatives to be mined, it's not
%   important for the function to find exactly 'num_samples' non-face
%   features, e.g. you might try to sample some number from each image, but
%   some images might be too small to find enough.

% 'features_neg' is N by D matrix where N is the number of non-faces and D
% is the template dimensionality, which would be
%   (feature_params.template_size / feature_params.hog_cell_size)^2 * 31
% if you're using the default vl_hog parameters

% Useful functions:
% vl_hog, HOG = VL_HOG(IM, CELLSIZE)
%  http://www.vlfeat.org/matlab/vl_hog.html  (API)
%  http://www.vlfeat.org/overview/hog.html   (Tutorial)
% rgb2gray

image_files = dir( fullfile( non_face_scn_path, '*.jpg' ));
num_images = length(image_files);
num_sample_per_img = ceil(num_samples/num_images);
D = (feature_params.template_size / feature_params.hog_cell_size)^2 * 31;
feat_size = feature_params.template_size;
features_neg = zeros(num_images, D);
for ii = 1:num_images
    img = im2single(rgb2gray(imread(strcat(non_face_scn_path, '/', image_files(ii).name))));
    [height, width] = size(img);
    for jj = 1:num_sample_per_img
        top_left_x = ceil(rand()*(width-feat_size));
        top_left_y = ceil(rand()*(height-feat_size));
        index = (ii-1)*num_sample_per_img + jj;
        cropped = img(top_left_y:top_left_y+feat_size-1, top_left_x:top_left_x+feat_size-1);
        features_neg(index,:) = reshape(vl_hog(cropped, feature_params.hog_cell_size), 1, D);
    end
end
    