function [img_features, labels] = ... 
    get_sketch_tokens(train_img_dir, train_gt_dir, feature_params, num_sketch_tokens)

% 'img_features' is N x feature dimension. You probably want it to be
% 'single' precision to save memory. 
% 'labels' is N x 1. labels(i) = 1 implies non-boundary, labels(i) = 2
% implies boundary or sketch token 1, labels(i) = 3 implies sketch token 2,
% etc... max(labels) should be num_sketch_tokens + 1;

%feature_params.CR = radius of the channel-derived patches. E.g. radius of
%7 would imply 15x15 features. The other entries of feature_params are for
%calling 'compute_daisy', but the starter code simply has the default
%DAISY values (which do work OK).

train_imgs = dir( fullfile( train_img_dir, '*.jpg' ));
% train_gts  = dir( fullfile( train_gt_dir,  '%.mat' )); %don't need to look them up, assume they exist for every image
num_imgs = length(train_imgs); % You don't need to sample them all while debugging.

num_samples = 30000;
pos_ratio   = 0.5; %The desired percentage of positive samples. 
n_pos = round(num_samples*pos_ratio);
n_neg = num_samples - n_pos;

%It's not critical that your function find exactly this many samples.

%14 channels
%3 color
%3 gradient magnitude
%4 + 4 oriented magnitudes

% Don't bother with sampling / clustering the sketch patches initially.
daisy_feature_dims = feature_params.RQ * feature_params.TQ * feature_params.HQ + feature_params.HQ;
sketch_features = zeros(n_pos, daisy_feature_dims, 'single');

%DELETE THIS PLACEHOLDER
%labels = round(rand(num_samples,1))+1;
%img_features = rand(num_samples,40);
%img_features = single(img_features); %needs to be single precision
CR = feature_params.CR;
patch_size = CR*2+1;
img_features = zeros(num_samples, patch_size*patch_size*14);
D=size(img_features,2);
pos_count = 0;
neg_count = 0;
pos_per_img = ceil(n_pos/num_imgs);
neg_per_img = ceil(n_neg/num_imgs);
for i = 1:num_imgs
    img_pos_count = 0;
    img_neg_count = 0;
    if pos_count == n_pos && neg_count == n_neg
        break
    end
    fprintf(' Sampling patches / annotations from %s\n', train_imgs(i).name);
    [cur_pathstr,cur_name,cur_ext] = fileparts(train_imgs(i).name);
    cur_img = imread(fullfile(train_img_dir, train_imgs(i).name));
    dzy = compute_daisy(cur_img);

    cur_gt  = zeros(size(cur_img,1), size(cur_img,2));
        
    annotation_struct  = load(fullfile(train_gt_dir, [cur_name '.mat']));
    
        
    for j = 1:length(annotation_struct.groundTruth)
        cur_gt = cur_gt + annotation_struct.groundTruth{j}.Boundaries; 
    end

    % Pad the current image and then call 'channels = get_channels(cur_img)'

    padded_img = im2single(imPad(cur_img, CR, 'symmetric'));
    channels = get_channels(padded_img);
        
    [pos_row, pos_col] = find(cur_gt);
    [neg_row, neg_col] = find(~cur_gt);
    
    num_positives = length(pos_row);
    num_negatives = length(neg_row);
    % Fill in some of the rows of img_features. Don't worry about filling
    % in sketch_features initially.
    for jj = 1:num_positives
        if img_pos_count == pos_per_img
            break
        end
        r = pos_row(jj);
        c = pos_col(jj);
        pos_count = pos_count+1;
        img_pos_count = img_pos_count+1;
        sketch_features(pos_count,:) = ...
            reshape(get_descriptor(dzy, r, c), 1, daisy_feature_dims);
        img_features(pos_count,:) = ...
            reshape(channels(r:r+2*CR,c:c+2*CR,:),1,D);
    end
    
    for jj = 1:num_negatives
        if img_neg_count == neg_per_img
            break
        end
        r = neg_row(jj);
        c = neg_col(jj);
        neg_count = neg_count+1;
        img_neg_count = img_neg_count+1;
        img_features(n_pos + neg_count,:) = ...
            reshape(channels(r:r+2*CR,c:c+2*CR,:),1,D);
    end

end

% [centers, assignments] = vl_kmeans(X, K)
%  http://www.vlfeat.org/matlab/vl_kmeans.html
%   X is a d x M matrix of sampled SIFT features, where M is the number of
%    features sampled. M should be pretty large! Make sure matrix is of type
%    single to be safe. E.g. single(matrix).
%   'K' is the number of clusters desired (vocab_size)
%   'centers' is a d x K matrix of cluster centers
%   'assignments' is a 1 x M uint32 vector specifying which cluster every
%       feature was assigned to.
%
%   In project 3, we cared about the universal vocabulary specified by
%   'centers'. Here we don't. We care about 'assignments', telling us which
%   sketch tokens (and therefore which image features) correspond to the
%   same mid level boundary structure. We will keep 'centers' only for the
%   sake of visualization.

% Only cluster the Sketch Patches which have center pixel boundaries.

[~, assignments] = vl_kmeans(sketch_features', num_sketch_tokens);

img_features = single(img_features);
labels = [assignments'+1; ones(n_neg, 1)];



