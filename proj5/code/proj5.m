%=============================================================
% functions you would need to modify:
% 0. This function, proj5.m
% 1. get_sketch_tokens.m
% 2. detect_sketch_tokens.m
%=============================================================

%See http://cs.brown.edu/courses/cs143/proj5/ for suggestions on how to
%implement the Sketch Tokens algorithm.


%%
%clear all;close all;

%% Set up
[~,~,~] = mkdir('visualizations');

%all three of these pieces of code have precompiled functions in 'mex'
%form. Most have been compiled for MacOS, Linux, and Windows. Let us know
%if you run into problems, though.

%VLFeat is not strictly necessary for this project. Might want to
%'vl_kmeans' instead of Matlab's 'kmeans'
run('vlfeat/toolbox/vl_setup'); 
addpath('daisy'); %modified daisy descriptor, http://cvlab.epfl.ch/software/daisy
addpath(genpath('./bench/')); %BSDS evaluation code
addpath(genpath('./piotr_toolbox/')) %Piotr Dollar's Matlab Toolbox, for random forest classifier and a few other functions.

train_img_dir = '../data/BSDS500/images/train/'; %not used by Sobel or Canny baselines, but used by Sketch Tokens
test_img_dir  = '../data/BSDS500/images/small_test/'; %contains only 10 test images
% test_img_dir  = '../data/BSDS500/images/medium_test/'; %contains only 25 test images. They seem to be slightly easier than the test set as a whole.
% test_img_dir = '../data/BSDS500/images/test/'; %full 200 image test set. Probably too slow for debugging use.
% val_img_dir = '../data/BSDS500/images/val'; %Optional to use these for validation. Don't train on them, though!

test_imgs = dir(fullfile(test_img_dir,'*.jpg')); %all test images

train_gt_dir = '../data/BSDS500/groundTruth/train/'; %need this to learn the sketch tokens and to determine which training features are positive and negative examples
test_gt_dir  = '../data/BSDS500/groundTruth/test/'; %need this for evaluation
%val_gt_dir   = '../data/BSDS500/groundTruth/val/'; %Optional

%Create folders to store boundary detection images. These images can be
%used in your writeup. The evaluation loads the images from these locations.
sobel_img_dir     = '../data/sobel_baseline/'; %thresholded sobel 
canny_img_dir     = '../data/canny_baseline/'; %canny edge
sketch_tokens_dir = '../data/sketch_tokens/';  %your implementation

%These folders hold text files created by the BSDS evaluation code.
sobel_eval_dir = '../data/sobel_baseline_eval/';
canny_eval_dir = '../data/canny_baseline_eval/';
sketch_tokens_eval_dir = '../data/sketch_tokens_eval/';

if (~exist(sobel_img_dir,'dir'));    mkdir(sobel_img_dir); end
if (~exist(canny_img_dir,'dir'));    mkdir(canny_img_dir); end
if (~exist(sketch_tokens_dir,'dir')); mkdir(sketch_tokens_dir); end


%% Baseline: detect boundaries using thresholded Sobel responses
% You do not need to modify this. You can safely comment this block out
% after you've run it once, because the intermediate results will stay in
% 'sobel_img_dir'

% sobel_pb_stack=cell(1,length(test_imgs));
% thresh=.04:.03:.3;
% for f=1:length(test_imgs)
%     fprintf('computing Sobel baseline #%d out of %d\n',f,length(test_imgs));
%         cur_img=rgb2gray(im2double(imread(fullfile(test_img_dir,test_imgs(f).name))));
%     pb=sobel_pb(cur_img,thresh);
%     figure(1);imshow(pb);pause(0.01);
%     [path, name, ext]=fileparts(test_imgs(f).name);
%     imwrite(pb,[sobel_img_dir, name,'.png'], 'png'); %sobel thresholded pb
% %     sobel_pb_stack{f}=pb;
% end


%% Baseline: detect boundaries using Canny
% You do not need to modify this. You can safely comment this block out
% after you've run it once, because the intermediate results will stay in
% 'canny_img_dir'

% thresh=.05:.1:0.95;
% sigma=1:1:4;
% for f=1:length(test_imgs)
%     fprintf('computing Canny baseline #%d out of %d\n',f,length(test_imgs));
%     cur_img  =rgb2gray(im2double(imread(fullfile(test_img_dir,test_imgs(f).name))));
%     pb=canny_pb(cur_img, thresh, sigma);
%     figure(1);imshow(pb);pause(0.01);
%     [path, name, ext]=fileparts(test_imgs(f).name);
%     imwrite(pb,[canny_img_dir,name,'.png'],'png'); %sobel thresholded pb
% end

%% Sketch tokens
% Your code here!

%The patch width should be _odd_ so that there is an unambiguous center
%pixel. The feature width is 35 in the Sketch Token paper, but you probably
%don't have enough memory to use such large features.

feature_params = struct('R', 15, 'RQ', 3, 'TQ', 8, 'HQ', 8, 'SI', 1, 'LI', 1, 'NT', 0, 'CR', 7);
% All of these except for the last are parameters for the Daisy descriptor.
% You don't really need to use this because they're all simply default
% values. The last field 'CR' is the radius of the channel features.

%DAISY parameters. See http://cvlab.epfl.ch/software/daisy/ 
% R  : radius of the descriptor. Width is radius*2 + 1 pixels
% RQ : number of rings 
% TQ : number of histograms on each ring (there is a central histogram cell, even if TQ = 0)
% HQ : number of bins of the histograms
% 
% SI : spatial interpolation enable/disable
% LI : layered interpolation enable/disable
% NT : normalization type:
%      0 = No normalization
%      1 = Partial Normalization
%      2 = Full Normalization
%      3 = Sift like normalization    

num_sketch_tokens = 16;

% a. Get Sketch Tokens and the training examples. From the training
%    directory, load pairs of images and annotations.
[img_features, labels] = get_sketch_tokens( train_img_dir, train_gt_dir, feature_params, num_sketch_tokens);
%labels(i) = 1 implies background. labels(i) = 2 implies sketch token 1, etc.

%% b. Train classifiers Sketch Token(s).
if( num_sketch_tokens ~= length(unique(labels)) - 1)  % -1 because of the background class
    error('Number of sketch tokens does not equal number of non-background categories')
end

% Example of training a random forest classifier. See 'help forestTrain'
fprintf('Training random forest\n')
pTrain={'M',20};
tic, forest=forestTrain( img_features, labels, pTrain); toc

%% Validation on new random feature set
validation = 0;
if(validation)
    %you can use val_features and val_labels below if you want to measure
    %your classifier's accuracy without doing full boundary detection.
    [val_features, val_labels] = get_sketch_tokens( val_img_dir, val_gt_dir, feature_params, num_sketch_tokens);
end

%% Examine learned classifiers
% You don't need to modify anything in the rest of this section. The
% section first evaluates _training_ error, which isn't ultimately what we
% care about, but it is a good sanity check. Your training error should be
% very low with a random forest. You can comment out this entire section
% after you have things working reasonably.
for i = 1:num_sketch_tokens
    fprintf('Initial classifier performance on train data:\n')
    [categories, probabilities] = forestApply(img_features,forest);
    
    confidences = probabilities(:,i) - 0.5; % -0.5 to make it zero centered
    label_vector = (labels == i)*2 - 1;
    [tp_rate, fp_rate, tn_rate, fn_rate] =  report_accuracy( confidences, label_vector );

    % Visualize how well separated the positive and negative examples are at
    % training time. Sometimes this can idenfity odd biases in your training
    % data. 
    bg_confs = confidences( label_vector < 0);
    bd_confs = confidences( label_vector > 0);
    figure(2); 
    plot(sort(bg_confs), 'r'); hold on
    plot(sort(bd_confs), 'g'); 
    plot([0 size(bg_confs,1)], [0 0], 'b');
    hold off;
    
    pause(0.01)
end

%% c. Detect Sketch Tokens in test images.
% Your code here!
for f=1:length(test_imgs)
    fprintf('Detecting Sketch Tokens #%d out of %d\n',f,length(test_imgs));
    cur_img = im2single(imread(fullfile(test_img_dir,test_imgs(f).name)));
        
    [pb] = detect_sketch_tokens(cur_img, forest, feature_params);
    
    %call stToEdges here or inside 'detect_sketch_tokens'

%     figure(201)
%     imagesc(pb)
%     figure(1);imshow(pb);pause(0.01);
    
    [path, name, ext]=fileparts(test_imgs(f).name);
    imwrite(pb,[sketch_tokens_dir,name,'.png'],'png');
end

%% evaluate the results from Sobel
%run only when the Sobel images change. Otherwise comment out to save time.
fprintf('Evaluating Sobel edges against human ground truth\n')

if (~exist(sobel_eval_dir,'dir')); mkdir(sobel_eval_dir); end
nthresh = 5;
tic;
boundaryBench(test_img_dir, test_gt_dir, sobel_img_dir, sobel_eval_dir, nthresh);
toc;


%% evaluate the results from Canny 
%run only when the Canny images change. Otherwise comment out to save time.
fprintf('Evaluating Canny edges against human ground truth\n')

if (~exist(canny_eval_dir,'dir')); mkdir(canny_eval_dir); end
nthresh = 5;
tic;
boundaryBench(test_img_dir, test_gt_dir, canny_img_dir, canny_eval_dir, nthresh);
toc;

%% evaluate the results from Sketch Tokens
fprintf('Evaluating Sketch tokens edges against human ground truth\n')

if (~exist(sketch_tokens_eval_dir,'dir')); mkdir(sketch_tokens_eval_dir); end
nthresh = 10;
tic;
boundaryBench(test_img_dir, test_gt_dir, sketch_tokens_dir, sketch_tokens_eval_dir, nthresh);
toc;


%% plot the precision recall curve
close all;
%number of colors and dirs must be the same
dirs{1}=sobel_eval_dir;
dirs{2}=canny_eval_dir;
dirs{3}=sketch_tokens_eval_dir;
colors={'g','m','k'};

%number of names should be 5+number of dirs
%these will appear in the legend of the plot
%the first five are precomputed and not evaluated on the fly
%chance is about .22, depending on how you measure it.
names={'Human','F score contours','Canny','gPb','chance','Sobel baseline','Canny baseline','Sketch Tokens'};
h=plot_eval_multidir(dirs,colors,names);
print(h,'-dpng','visualizations/PR_curve.png');

%note the dotted lines are copied from figure 17 in the 2011 PAMI paper

%from Table 1 of Sketch Tokens, Lim et al. 2013 and other sources
% Pb, Martin, Fowlkes, Malik PAMI 2004 - .67
% gPb local, Arbelaez, Maire, Fowlkes, Malik PAMI 2011 - ODS .71, OIS .74, AP .65
% gPB global                                             ODS .73, OIS .76, AP .73
% Sketch Tokens  ODS .73, OIS .75, AP .78
% Humans, ODS .80, OIS .80