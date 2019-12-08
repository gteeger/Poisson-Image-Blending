function  output = imblend( source, mask, target, transparent )
    %Source, mask, and target are the same size (as long as you do not remove
    %the call to fiximages.m). You may want to use a flag for whether or not to
    %treat the source object as 'transparent' (e.g. taking the max gradient
    %rather than the source gradient).
    
    lap_mask=[0 1 0; 1 -4 1; 0 1 0];
    
    %output = source .* mask + target .* ~mask;
    
    
    [sc_rows, sc_cols, sc_z] = size(source);
    [tg_rows, tg_cols, tg_z] = size(target);
    
    
    
    
    location = zeros(sc_rows, sc_cols);
    idx = 0;
    %we need a lookup table for the image
    
    for row = 1:sc_rows
        for col = 1: sc_cols
            if mask(row,col,:) == 1
                

                
                if row == 1 || row == sc_rows || col == 1 || col == sc_cols
                    mask(row,col,:) = 0; 
                    
                else
                    idx = idx + 1;
                    location(row,col) = idx;
                end
                %while we are here, pad the mask
                
                
            end
        end
    end
    total_idx = idx;
    
    % for z = 1:sc_z
    
    
    
    
    result = zeros(sc_rows,sc_cols,3);
    
    for z = 1:sc_z %RGB
        tic
        temp_result = zeros(sc_rows,sc_cols);
        %create the laplacian of the source image
        
        idx = 0;
        A = spalloc(total_idx, total_idx,total_idx);
        B = zeros(total_idx,1);
        lap=conv2(source(:,:,z),lap_mask, 'same');
        
        for row = 1:sc_rows
            
            for col = 1: sc_cols
                
                if mask(row,col,:) == 1
                    idx = idx + 1;
                    A(idx,idx) = 4;
                    
                    %%%%%%%%%%%%BORDER CASES
                    
                    
                    %look up
                    if mask(row-1,col,:) ~=0
                        A(idx,location(row-1, col)) = -1;
                    else
                        B(idx) = B(idx) + target(row-1, col,z);
                    end
                    
                    %look left
                    if mask(row,col-1,:) ~=0
                        A(idx,location(row, col-1))= -1;
                    else
                        B(idx) = B(idx) + target(row, col-1,z);
                    end
                    
                    %look right
                    if mask(row,col+1,:) ~=0
                        A(idx,location(row, col+1))= -1;
                    else
                        B(idx) = B(idx) + target(row, col+1,z);
                    end
                    
                    %look down
                    if mask(row+1,col,:) ~=0
                        A(idx,location(row+1, col))= -1;
                    else
                        B(idx) = B(idx) + target(row+1, col,z);
                    end
                    
                    
                    B(idx)=B(idx)-lap(row,col);
                    
                end
                
            end
            
        end
        
        Y= A\B;
        
        for i = 1:total_idx
            
            [row_f, col_f] = find(location == i);
            temp_result(row_f,col_f)=Y(i,:);
            
        end
        result(:,:,z) = temp_result;
        toc
    end
    output = result .* mask + target .* ~mask;
end
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% As explained on the web page, we solve for output by setting up a large
% system of equations, in matrix form, which specifies the desired value or
% gradient or Laplacian (e.g.
% http://en.wikipedia.org/wiki/Discrete_Laplace_operator)

% The comments here will walk you through a conceptually simple way to set
% up the image blending, although it is not necessarily the most efficient
% formulation.

% We will set up a system of equations A * x = b, where A has as many rows
% and columns as there are pixels in our images. Thus, a 300x200 image will
% lead to A being 60000 x 60000. 'x' is our output image (a single color
% channel of it) stretched out as a vector. 'b' contains two types of known
% values:
%  (1) For rows of A which correspond to pixels that are not under the
%      mask, b will simply contain the already known value from 'target'
%      and the row of A will be a row of an identity matrix. Basically,
%      this is our system of equations saying "do nothing for the pixels we
%      already know".
%  (2) For rows of A which correspond to pixels under the mask, we will
%      specify that the gradient (actually the discrete Laplacian) in the
%      output should equal the gradient in 'source', according to the final
%      equation in the webpage:
%         4*x(i,j) - x(i-1, j) - x(i+1, j) - x(i, j-1) - x(i, j+1) =
%         4*s(i,j) - s(i-1, j) - s(i+1, j) - s(i, j-1) - s(i, j+1)
%      The right hand side are measurements from the source image. The left
%      hand side relates different (mostly) unknown pixels in the output
%      image. At a high level, for these rows in our system of equations we
%      are saying "For this pixel, I don't know its value, but I know that
%      its value relative to its neighbors should be the same as it was in
%      the source image".

% commands you may find useful:
%   speye - With the simplest formulation, most rows of 'A' will be the
%      same as an identity matrix. So one strategy is to start with a
%      sparse identity matrix from speye and then add the necessary
%      values. This will be somewhat slow.
%   sparse - if you want your code to run quickly, compute the values and
%      indices for the non-zero entries in A and then construct 'A' with a
%      single call to 'sparse'.
%      Matlab documentation on what's going on under the hood with a sparse
%      matrix: www.mathworks.com/help/pdf_doc/otherdocs/simax.pdf
%   reshape - convert x back to an image with a single call.
%   sub2ind and ind2sub - how to find correspondence between rows of A and
%      pixels in the image. It's faster if you simply do the conversion
%      yourself, though.
%   see also find, sort, diff, cat, and spy


