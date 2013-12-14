%This function visualizes detections in order of decreasing confidence, one
%at a time.
function visualize_detections_by_confidence(bboxes, confidences, image_ids, test_scn_path, label_path, onlytp)
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

% sort detections by decreasing confidence
[sc,si]=sort(-confidences);
image_ids=image_ids(si);
bboxes   =bboxes(si,:);

nd=length(confidences);

for d=1:nd
    cur_gt_ids = strcmp(image_ids{d}, gt_ids); %will this be slow?

    bb = bboxes(d,:);
    ovmax=-inf;

    if(~any(cur_gt_ids)) %this test image had no faces
        continue;
    end
    
    for j = find(cur_gt_ids')
        bbgt=gt_bboxes(j,:);
        bi=[max(bb(1),bbgt(1)) ; max(bb(2),bbgt(2)) ; min(bb(3),bbgt(3)) ; min(bb(4),bbgt(4))];
        iw=bi(3)-bi(1)+1;
        ih=bi(4)-bi(2)+1;
        if iw>0 && ih>0                
            % compute overlap as area of intersection / area of union
            ua=(bb(3)-bb(1)+1)*(bb(4)-bb(2)+1)+...
               (bbgt(3)-bbgt(1)+1)*(bbgt(4)-bbgt(2)+1)-...
               iw*ih;
            ov=iw*ih/ua;
            if ov>ovmax %higher overlap than the previous best?
                ovmax=ov;
                jmax=j;
            end
        end
    end
    
    % skip false positives
    if onlytp && ovmax<VOCopts.minoverlap
        continue
    end
    
    % read image
    I=imread( fullfile( test_scn_path, image_ids{d}) );

    % draw detection bounding box and ground truth bounding box (if any)
    figure(14)
    imshow(I);
    hold on;
    if ovmax>=0.3
        bbgt=gt_bboxes(jmax,:);
        plot(bbgt([1 3 3 1 1]),bbgt([2 2 4 4 2]),'y-','linewidth',2);
        plot(bb([1 3 3 1 1]),bb([2 2 4 4 2]),'g:','linewidth',2);
    else
        plot(bb([1 3 3 1 1]),bb([2 2 4 4 2]),'r-','linewidth',2);
    end    
    hold off;
    axis image;
    axis off;
    title(sprintf('det %d/%d: image: "%s" (green=true pos,red=false pos,yellow=ground truth)',...
            d,nd,image_ids{d}),'interpreter','none');
    
    fprintf('press any key to continue with next image\n');
    pause;
    
end




