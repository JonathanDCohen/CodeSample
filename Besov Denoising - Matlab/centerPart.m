function out = centerPart(M, MAXSCALES, scale)
%FUNCTION OUT = CENTERPART(M, MAXSCALES, SCALES) extracts the central
%portion of the matrix M representing actual data instead of the padding
%used as boundary conditions in gradient and divergence calculations.
%
%INPUTS:
%   M: the matrix for which to find the central part.  Can be a regular 2d
%       matrix or a multidimensional matrix of up to 4 dimensions, in which
%       case the central portion of each 2d slice is extracted.
%   MAXSCALES: the maximum number of scales being considered for gradients
%       and divergences.
%   scale(optional): the scale of finite difference which M represents if
%       it is an intermediate result in a gradient or divergence
%       calculation.  Defaults to 0.
%
%OUTPUTS:
%   out: the central portion of M
%Code by Jonathan Cohen, Duquesne University

if nargin < 3
    scale = 0;
end
out = M((MAXSCALES + 1 - scale):(end - MAXSCALES + scale),...
        (MAXSCALES + 1 - scale):(end - MAXSCALES + scale), :, :); 