function first = binarySearch(v, nu)
%FUNCTION FIRST = BINARYSEARCH(V, NU) searches for an entry in 
%non-increasing list v such that v(i) <= nu <= v(i+1).
%
%INPUTS
%   v - non-increasing list to search
%   nu - search key
%
%OUTPUTS
%   first - index found in list
%
%Code by Jonathan Cohen, Duquesne Univeristy, April 2013

first = 1;
last = length(v);
if v(last) <= nu
    first = last;
    return;
end

while (last - 1) > first
    mid = floor(.5*(first + last));
    if v(mid) <= nu
        first = mid;
    else %v(mid) > nu
        last = mid;
    end 
end

