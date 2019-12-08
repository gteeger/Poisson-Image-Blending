function [ mask ] = getmask(img)

% Taken from the Matlab Help and modified for csci1290
% author: Patrick Doran
% login: pdoran

img = im2double(img);

h = figure;
imshow(img);
hold on


% Initially, the list of points is empty.
xy = [];
n = 0;
% Loop, picking up the points.
disp('Left mouse button picks points.')
disp('Right mouse button picks last point.')
but = 1;
while but == 1
    [xi,yi,but] = ginput(1);
    plot(xi,yi,'ro')
    n = n+1;
    xy(:,n) = [xi;yi];
end

xy = cat(2,xy,[xy(1,1);xy(2,1)]);

mask = poly2mask(xy(1,:),xy(2,:),size(img,1),size(img,2));
mask = repmat(mask,[1 1 3]);
mask = double(mask);

hold off
close(h);
drawnow

end