%This function visualizes all detections in each test image
function visualize_detections_by_image(bboxes, confidences, image_ids, tp, fp, test_scn_path, label_path, onlytp)
% 'bboxes' is Nx4, N is the number of non-overlapping detections, and each
% row is [x_min, y_min, x_max, y_max]
% 'confidences' is the Nx1 (final cascade node) confidence of each
% detection.
% 'image_ids' is the Nx1 image names for each detection.

%This code is modified from the 2010 Pascal VOC toolkit.
%http://pascallin.ecs.soton.ac.uk/challenges/VOC/voc2010/index.html#devkit

if(~exist('onlytp', 'var'))
    onlytp = false;
end

fid = fopen(label_path);
gt_info = textscan(fid, '%s %d %d %d %d');
fclose(fid);
gt_ids = gt_info{1,1};
gt_bboxes = [gt_info{1,2}, gt_info{1,3}, gt_info{1,4}, gt_info{1,5}];
gt_bboxes = double(gt_bboxes);

gt_file_list = unique(gt_ids);

num_test_images = length(gt_file_list);

for i=1:num_test_images
   if (~exist(strcat(test_scn_path,'/',gt_file_list{i}),'file'))
       continue
   end
   cur_test_image = imread( fullfile( test_scn_path, gt_file_list{i}));
   cur_gt_detections = strcmp( gt_file_list{i}, gt_ids);
   cur_gt_bboxes = gt_bboxes(cur_gt_detections ,:);
   
   cur_detections = strcmp(gt_file_list{i}, image_ids);
   cur_bboxes = bboxes(cur_detections,:);
   cur_confidences = confidences(cur_detections);
   cur_tp = tp(cur_detections);
   cur_fp = fp(cur_detections);
   
   figure(15)
   imshow(cur_test_image);
   hold on;
   
   num_detections = sum(cur_detections);
   
   for j = 1:num_detections
       bb = cur_bboxes(j,:);
       if(cur_tp(j)) %this was a correct detection
           plot(bb([1 3 3 1 1]),bb([2 2 4 4 2]),'g:','linewidth',2);
       elseif(cur_fp(j))
           plot(bb([1 3 3 1 1]),bb([2 2 4 4 2]),'r-','linewidth',2);
       else
           error('a detection was neither a true positive or a false positive')
       end
   end
   
   num_gt_bboxes = size(cur_gt_bboxes,1);

   for j=1:num_gt_bboxes
       bbgt=cur_gt_bboxes(j,:);
       plot(bbgt([1 3 3 1 1]),bbgt([2 2 4 4 2]),'y-','linewidth',2);
   end
 
   hold off;
   axis image;
   axis off;
   title(sprintf('image: "%s" (green=true pos, red=false pos, yellow=ground truth), %d/%d found',...
                 gt_file_list{i}, sum(cur_tp), size(cur_gt_bboxes,1)),'interpreter','none');
             
   set(15, 'Color', [.988, .988, .988])
   pause(0.1) %let's ui rendering catch up
   detection_image = frame2im(getframe(15));
   % getframe() is unreliable. Depending on the rendering settings, it will
   % grab foreground windows instead of the figure in question. It could also
   % return a partial image.
   imwrite(detection_image, sprintf('visualizations/detections_%s.png', gt_file_list{i}))
    
   fprintf('press any key to continue with next image\n');
   pause;
end



