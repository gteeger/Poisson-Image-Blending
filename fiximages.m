function [ source, mask, target ] = fiximages(source, mask, target, offset)
[ tar_tblr, src_tblr ] = bounds( source, target, offset );

new_mask = zeros(size(target));
new_src = zeros(size(target));

a = tar_tblr(1):tar_tblr(2);
b = tar_tblr(3):tar_tblr(4);
c = src_tblr(1):src_tblr(2);
d = src_tblr(3):src_tblr(4);
new_mask(a,b,:) = mask(c,d,:);
new_src(a,b,:) = source(c,d,:);

source = new_src;
mask = new_mask;
target = target;
end

function [ tar_tblr, src_tblr ] = bounds( source, target, offset )

src_sz = size(source);
tar_sz = size(target);

tar_t   = max(1, offset(1)+1);
tar_b   = min( tar_sz(1), offset(1)+src_sz(1));
tar_l   = max(1, offset(2)+1);
tar_r   = min( tar_sz(2), offset(2)+src_sz(2));

tar_t   = min(tar_sz(1), tar_t);
tar_b   = max(1, tar_b);
tar_l   = min(tar_sz(2),tar_l);
tar_r   = max(1,tar_r);


src_t   = ternary( offset(1) >= 0, 1, 1-offset(1));
src_b   = ternary( offset(1)+src_sz(1) <= tar_sz(1), src_sz(1), tar_sz(1)-offset(1) );
src_l   = ternary( offset(2) >= 0, 1, 1-offset(2));
src_r   = ternary( offset(2)+src_sz(2) <= tar_sz(2), src_sz(2), tar_sz(2)-offset(2) );

src_t   = min(src_sz(1), src_t);
src_b   = max(1, src_b);
src_l   = min(src_sz(2), src_l);
src_r   = max(1, src_r);


tar_tblr = [ tar_t, tar_b, tar_l, tar_r ];
src_tblr = [ src_t, src_b, src_l, src_r ];
end

function out = ternary( condition, first, second)
    if condition
        out = first;
    else
        out = second;
    end
end