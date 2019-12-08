close all
clear all;

data_dir = 'data';
out_dir = 'results';

charlie_offset = [ 865  675 ];

my_offset = charlie_offset;

%for i = 6:length(offset)
load ("my_images/sunglasses_source.mat");

%for i = 1:1
mask(:,:,1) = msk;
mask(:,:,2) = msk;
mask(:,:,3) = msk;
target = imread("my_images/charlie.jpg");

src = im2double(src);

mask = round(im2double(mask));
target = im2double(target);

% Interactive mask
% mask = getmask(source);

[source, mask, target] = fiximages(src, mask, target, my_offset);

output = imblend(source, mask, target);

imwrite(output,sprintf('%s/result_charlie_hq.jpg',out_dir),'jpg','Quality',100);

figure
imshow(output)


