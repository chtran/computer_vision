% Automated Panorama Stitching stencil code
% CS 143 Computational Photography, Brown U.
% Written by James Hays

% Visualizes corresponding points between two images. Corresponding points
% will have the same random color.

% You do not need to modify anything in this function, although you can if
% you want to.
function [ h ] = show_correspondence(image1, image2, X1, Y1, X2, Y2)

h = figure;
set(h, 'Position', [100 100 800 600])
subplot(1,2,1);
imshow(image1, 'Border', 'tight')
subplot(1,2,2);
imshow(image2, 'Border', 'tight')

for i = 1:size(X1,1)
    cur_color = rand(3,1);
    subplot(1,2,1);
    hold on;
    plot(X1(i),Y1(i), 'o', 'LineWidth',2, 'MarkerEdgeColor','k',...
                       'MarkerFaceColor', cur_color, 'MarkerSize',10)

    hold off;
   
    subplot(1,2,2);
    hold on;
    plot(X2(i),Y2(i), 'o', 'LineWidth',2, 'MarkerEdgeColor','k',...
                       'MarkerFaceColor', cur_color, 'MarkerSize',10)
    hold off;
end

fprintf('Saving visualization to vis.jpg\n')
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
imwrite(visualization_image, 'vis.jpg', 'quality', 100)