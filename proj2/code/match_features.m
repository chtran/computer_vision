% Local Feature Stencil Code
% CS 143 Computater Vision, Brown U.
% Written by James Hays

% 'features1' and 'features2' are the n x feature dimensionality features
%   from the two images.
% If you want to include geometric verification in this stage, you can add
% the x and y locations of the features as additional inputs.
%
% 'matches' is a k x 2 matrix, where k is the number of matches. The first
%   column is an index in features 1, the second column is an index
%   in features2. 
% 'Confidences' is a k x 1 matrix with a real valued confidence for every
%   match.
% 'matches' and 'confidences' can empty, e.g. 0x2 and 0x1.
function [matches, confidences] = match_features(features1, features2)

% This function does not need to be symmetric (e.g. it can produce
% different numbers of matches depending on the order of the arguments).

% To start with, simply implement the "ratio test", equation 4.18 in
% section 4.1.3 of Szeliski. For extra credit you can implement various
% forms of spatial verification of matches.

% Placeholder that you can delete. Random matches and confidences

threshold = 0.70;
dist_matrix = pdist2(features1, features2, 'euclidean');


[sorted_dist_matrix, indices] = sort(dist_matrix, 2);
inverse_confidences = (sorted_dist_matrix(:,1)./sorted_dist_matrix(:,2));
confidences = 1./inverse_confidences(inverse_confidences < threshold);

matches = zeros(size(confidences,1), 2);
matches(:,1) = find(inverse_confidences < threshold);
matches(:,2) = indices(inverse_confidences < threshold, 1);

% Sort the matches so that the most confident onces are at the top of the
% list. You should probably not delete this, so that the evaluation
% functions can be run on the top matches easily.
[confidences, ind] = sort(confidences, 'descend');
matches = matches(ind,:);