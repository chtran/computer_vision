function [ pb ] = canny_pb( im,thresh,sigma )
%  canny version
pb=im*0;
for t=thresh
    for s=sigma
        cur_edges = single(edge(im,'canny',t,s));
%         figure(3)
%         imagesc(cur_edges)
%         pause
        pb=pb+cur_edges;
    end
end
%linear scale : 0 to 1
low=min(pb(:));
high=max(pb(:));
pb=(pb-low)/(high-low);
end

