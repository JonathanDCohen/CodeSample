function out = Lp(im, p)
%FUNCTION OUT = LP(IM, P) calculates the Lp norm of an image constrained to
%the unit square.
%
%INPUTS:
%   im: the matrix to calculate the Lp norm of
%   p: either a number representing the Lp space to use, or a struct with a
%       field Lp containing that number.  The struct is useful in some
%       automated testing of various smoothness norms.
%
%OUTPUTS:
%   out: the Lp norm of im
%Code by Jonathan Cohen, July 2013

if isstruct(p)
    p = p.Lp;
end

if isfinite(p)
    out = sum(sum((abs(double(im)) .^ p)/numel(im))) ^ (1/p);
elseif p > 0
    out = max(max(abs(double(im))));
else 
    out = min(min(abs(double(im))));
end