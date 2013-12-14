test_image = rgb2gray(im2single(imread('../data/Notre Dame/4191453057_c86028ce1f_o.jpg')));

hold on;
figure(1);
colormap(gray)
axis equal;
axis off
imagesc(test_image);
[x, y, confidence] = get_interest_points(test_image, 16);
plot(x,y,'*');
title('Interest points detected using connected components');
set(gca,'YDir','reverse')
