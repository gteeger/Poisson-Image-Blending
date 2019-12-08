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
                %while we are here, pad the mask
                if row == 1 || row == sc_rows || col == 1 || col == sc_cols
                    mask(row,col,:) = 0; 
                else
                    idx = idx + 1;
                    location(row,col) = idx;
                end
            end
        end
    end
    total_idx = idx;
    

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

