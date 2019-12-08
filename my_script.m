% Starter script for CSCI 1290 project on Poisson blending.
% Written by James Hays and Pat Doran.
% imblend.m is the function where you will implement your blending method.
% By default, imblend.m performs a direct composite.

close all
clear all;

data_dir = 'data';
out_dir = 'results';

%there are four inputs for each compositing operation --
% 1. 'source' image. Parts of this image will be inserted into 'target'
% 2. 'mask' image. This binary image, the same size as 'source', specifies
%     which pixels will be copied to 'target'
% 3. 'target' image. This is the destination for the 'source' pixels under
%     the 'mask'
% 4. 'offset' vector. This specifies how much to translate the 'source'
%     pixels when copying them to 'target'. These vectors are hard coded
%     below for the default test cases. They are of the form [y, x] where
%     positive values mean shifts down and to the right, respectively.


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


