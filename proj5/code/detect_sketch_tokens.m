function pb = detect_sketch_tokens(img, forest, feature_params)

% 'img' is a test image.
% 'forest' is the structure returned by 'forestTrain'.

% 'pb' is the probability of boundary for every pixel.

%feature_params.CR = radius of the channel-derived patches. E.g. radius of
%7 would imply 15x15 features. The other entries of feature_params are for
%calling 'compute_daisy', which you probably don't need here (unless you've
%decided to use the DAISY descriptor as an image feature, which might be a
%decent idea).

[height, width, cc] = size(img);
num_sketch_tokens = max(forest(1).hs) - 1; %-1 for background class
CR = feature_params.CR;


% Pad the current image and then call 'channels = get_channels(cur_img)'
height = size(img, 1);
width = size(img, 2);
padded_img = imPad(img, CR, 'symmetric');
channels = get_channels(padded_img);
patch_size = CR*2+1;
D = patch_size * patch_size * 14;
patches = zeros(width*height, D);
for r=1:height
    for c=1:width
        patches((r-1)*width+c,:) = reshape(channels(r:r+2*CR,c:c+2*CR,:),1,D);
    end
end
patches = single(patches);
% Stack all of the image features into one matrix. This will be redundant
% (a single pixel will appear in many patches) but it will be faster than
% calling 'forestApply' for every single pixel.

% Call 'forestApply', use the resulting probabilities to build the output
% 'pb'
[categories, probabilities] = forestApply(patches, forest);
edge_probabilities = sum(probabilities(:,2:end),2);
pb = reshape(edge_probabilities, width, height)';

gaussian = fspecial('Gaussian', [5 5], 1.5);
pb = imfilter(pb, gaussian);

pb = stToEdges(pb,1,1);
