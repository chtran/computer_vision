function [is_valid_bbox] = non_max_supr_bbox(bboxes, confidences, img_size, verbose)
% high confidence detections suppress all overlapping detections (including
% detections at other scales). Detections can partially overlap, but the
% center of one detection can not be within another detection.

% 'bboxes' is Nx4, N is the number of non-overlapping detections, and each
% row is [x_min, y_min, x_max, y_max]
% 'confidences' is the Nx1 (final cascade node) confidence of each
% detection.
% 'img_size' is the [y,x] dimensions of the image.

% is_valid_bbox is a logical array of Nx1
% 'bboxes' is Nx4, N is the number of non-overlapping detections, and each
% row is [x_min, y_min, x_max, y_max]
% 'confidences' is the Nx1 (final cascade node) confidence of each
% detection.

% code for computing overlap from the 2010 Pascal VOC toolkit.
% http://pascallin.ecs.soton.ac.uk/challenges/VOC/voc2010/index.html#devkit


if(~exist('verbose', 'var'))
    verbose = false;
end

%Truncate bounding boxes to image dimensions
x_out_of_bounds = bboxes(:,3) > img_size(2); %xmax is greater than x dimension
y_out_of_bounds = bboxes(:,4) > img_size(1); %ymax is greater than y dimension

bboxes(x_out_of_bounds,3) = img_size(2);
bboxes(y_out_of_bounds,4) = img_size(1);

%if(verbose)
%    fprintf('warning: %d out of %d detections out of x bounds\n', sum(x_out_of_bounds), num_detections)
%    fprintf('warning: %d out of %d detections out of y bounds\n', sum(y_out_of_bounds), num_detections)
%end

num_detections = size(confidences,1);

%higher confidence detections get priority.
[confidences, ind] = sort(confidences, 'descend');
bboxes = bboxes(ind,:);

% indicator for whether each bbox will be accepted or suppressed
is_valid_bbox = logical(zeros(1,num_detections)); 

for i = 1:num_detections
    cur_bb = bboxes(i,:);
    cur_bb_is_valid = true;
    
    for j = find(is_valid_bbox)
        %compute overlap with each previously confirmed bbox.
        
        prev_bb=bboxes(j,:);
        bi=[max(cur_bb(1),prev_bb(1)) ; ... 
            max(cur_bb(2),prev_bb(2)) ; ...
            min(cur_bb(3),prev_bb(3)) ; ...
            min(cur_bb(4),prev_bb(4))];
        iw=bi(3)-bi(1)+1;
        ih=bi(4)-bi(2)+1;
        if iw>0 && ih>0                
            % compute overlap as area of intersection / area of union
            ua=(cur_bb(3)-cur_bb(1)+1)*(cur_bb(4)-cur_bb(2)+1)+...
               (prev_bb(3)-prev_bb(1)+1)*(prev_bb(4)-prev_bb(2)+1)-...
               iw*ih;
            ov=iw*ih/ua;
            if ov > 0.3 %If the less confident detection overlaps too much with the previous detection
                cur_bb_is_valid = false;
            end
            
            %special case-- the center coordinate of the current bbox is
            %inside the previous bbox.
            center_coord = [(cur_bb(1) + cur_bb(3))/2, (cur_bb(2) + cur_bb(4))/2];
            if( center_coord(1) > prev_bb(1) && center_coord(1) < prev_bb(3) && ...
                center_coord(2) > prev_bb(2) && center_coord(2) < prev_bb(4))
               
                cur_bb_is_valid = false;
            end
            
            if(verbose)
                fprintf('detection %d, bbox: [%d %d %d %d], %f overlap with %d [%d %d %d %d]\n', ...
                    i, cur_bb(1), cur_bb(2), cur_bb(3), cur_bb(4), ov, j, prev_bb(1), prev_bb(2), prev_bb(3),prev_bb(4))
            end
        end
    end
    
    is_valid_bbox(i) = cur_bb_is_valid;

end

%This statement returns the logical array 'is_valid_bbox' back to the order
%of the input bboxes and confidences
reverse_map(ind) = 1:num_detections;
is_valid_bbox = is_valid_bbox(reverse_map);


fprintf(' non-max suppression: %d detections to %d final bounding boxes\n', num_detections, sum(is_valid_bbox));


