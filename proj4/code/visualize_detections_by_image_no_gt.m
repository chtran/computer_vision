%This function visualizes all detections in each test image
function visualize_detections_by_image_no_gt(bboxes, confidences, image_ids, test_scn_path)
% 'bboxes' is Nx4, N is the number of non-overlapping detections, and each
% row is [x_min, y_min, x_max, y_max]
% 'confidences' is the Nx1 (final cascade node) confidence of each
% detection.
% 'image_ids' is the Nx1 image names for each detection.

%This code is modified from the 2010 Pascal VOC toolkit.
%http://pascallin.ecs.soton.ac.uk/challenges/VOC/voc2010/index.html#devkit


test_files = dir(fullfile(test_scn_path, '*.jpg'));
num_test_images = length(test_files);

for i=1:num_test_images
   cur_test_image = imread( fullfile( test_scn_path, test_files(i).name));
      
   cur_detections = strcmp(test_files(i).name, image_ids);
   cur_bboxes = bboxes(cur_detections,:);
   cur_confidences = confidences(cur_detections);
   
   figure(15)
   imshow(cur_test_image);
   hold on;
   
   num_detections = sum(cur_detections);
   
   for j = 1:num_detections
       bb = cur_bboxes(j,:);
       plot(bb([1 3 3 1 1]),bb([2 2 4 4 2]),'g:','linewidth',2);
   end
 
   hold off;
   axis image;
   axis off;
   title(sprintf('image: "%s" green=detection', test_files(i).name),'interpreter','none');
    
   set(15, 'Color', [.988, .988, .988])
   pause(0.1) %let's ui rendering catch up
   detection_image = frame2im(getframe(15));
   % getframe() is unreliable. Depending on the rendering settings, it will
   % grab foreground windows instead of the figure in question. It could also
   % return a partial image.
   imwrite(detection_image, sprintf('visualizations/detections_%s.png', test_files(i).name))
   
   fprintf('press any key to continue with next image\n');
   pause;
end



