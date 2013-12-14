% Local Feature Stencil Code
% CS 143 Computater Vision, Brown U.
% Written by James Hays

% You do not need to modify anything in this function, although you can if
% you want to.
function evaluate_correspondence(x1_est, y1_est, x2_est, y2_est)

ground_truth_correspondence_file = '../data/Notre Dame/921919841_a30df938f2_o_to_4191453057_c86028ce1f_o.mat';
image1 = imread('../data/Notre Dame/921919841_a30df938f2_o.jpg');
image2 = imread('../data/Notre Dame/4191453057_c86028ce1f_o.jpg');

good_matches = zeros(length(x1_est),1); %indicator vector

load(ground_truth_correspondence_file)
%loads variables x1, y1, x2, y2
%   x1                       91x1                  728  double                         
%   x2                       91x1                  728  double                     
%   y1                       91x1                  728  double                      
%   y2                       91x1                  728  double              

h = figure;
set(h, 'Position', [100 100 800 600])
subplot(1,2,1);
imshow(image1, 'Border', 'tight')
subplot(1,2,2);
imshow(image2, 'Border', 'tight')


for i = 1:length(x1_est)
    
    fprintf('( %4.0f, %4.0f) to ( %4.0f, %4.0f)', x1_est(i), y1_est(i), x2_est(i), y2_est(i));
        
    %for each x1_est, find nearest ground truth point in x1
    x_dists = x1_est(i) - x1;
    y_dists = y1_est(i) - y1;
    dists = sqrt(  x_dists.^2 + y_dists.^2 );
    
    [dists, best_matches] = sort(dists);
    
    current_offset = [x1_est(i) - x2_est(i), y1_est(i) - y2_est(i)];
    most_similar_offset = [x1(best_matches(1)) - x2(best_matches(1)), y1(best_matches(1)) - y2(best_matches(1))];
    
    %match_dist = sqrt( (x2_est(i) - x2(best_matches(1)))^2 + (y2_est(i) - y2(best_matches(1)))^2);
    match_dist = sqrt( sum((current_offset - most_similar_offset).^2));
    
    %A match is bad if there's no ground truth point within 150 pixels or
    %if nearest ground truth correspondence offset isn't within 25 pixels
    %of the estimated correspondence offset.
    fprintf(' g.t. point %4.0f px. Match error %4.0f px.', dists(1), match_dist);
    
    if(dists(1) > 150 || match_dist > 25)
        good_matches(i) = 0;
        edgeColor = [1 0 0];
        fprintf('  incorrect\n');
    else
        good_matches(i) = 1;
    	edgeColor = [0 1 0];
        fprintf('  correct\n');
    end

    cur_color = rand(1,3);
    subplot(1,2,1);
    hold on;
    plot(x1_est(i),y1_est(i), 'o', 'LineWidth',2, 'MarkerEdgeColor',edgeColor,...
                       'MarkerFaceColor', cur_color, 'MarkerSize',10)
    hold off;

    subplot(1,2,2);
    hold on;
    plot(x2_est(i),y2_est(i), 'o', 'LineWidth',2, 'MarkerEdgeColor',edgeColor,...
                       'MarkerFaceColor', cur_color, 'MarkerSize',10)
    hold off;
end

fprintf('%d total good matches, %d total bad matches\n', sum(good_matches), length(x1_est) - sum(good_matches))

fprintf('Saving visualization to eval.jpg\n')
visualization_image = frame2im(getframe(h));
% getframe() is unreliable. Depending on the rendering settings, it will
% grab foreground windows instead of the figure in question. It could also
% return an image that is not 800x600 if the figure is resized or partially
% off screen.
try
    %trying to crop some of the unnecessary boundary off the image
    visualization_image = visualization_image(81:end-80, 51:end-50,:);
catch
    ;
end
imwrite(visualization_image, 'eval.jpg', 'quality', 100)
