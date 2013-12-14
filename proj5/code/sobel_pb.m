function [ pb ] = sobel_pb( im,thresh )
% compute pb for each pixel based on thresholded sobel responses
pb=im*0;
for t=thresh
    pb=pb+single(edge(im,'sobel',t));
end
%linear scale : 0 to 1
low=min(pb(:));
high=max(pb(:));
pb=(pb-low)/(high-low);

end

