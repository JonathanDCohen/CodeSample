function mask = buildMask(MAXSCALES, hVert, hHorz, hDiag)
%FUNCTION MASK = BUILDMASK(MAXSCALES, HVERT, HHORZ, HDIAG) builds a cell
%array of convolution masks representing 2nd-order finite differences
%over a range of scales, in the vertical, horizontal, and two diagonal
%directions.
%
%INPUTS:   
%   MAXSCALES: the number of scales for which to create masks.  The final 
%           array is MAXSCALES x 4 in size.
%   hVert, hHorz, hDiag: the vertical, horizontal, and diagonal grid sizes,
%           respectively, for the current image being denoised.
%
%OUTPUTS:
%   mask: the cell array of filter masks
%
%Code written by Jonathan Cohen, Duquesne University, July 2013

mask = cell(4, MAXSCALES);
for j = 1:MAXSCALES
    jplus = j + 1; 
    sze = 2*j + 1; 
    template = zeros(2*j + 1); 

    m = template;
    m(1, jplus) = 1; m(jplus, jplus) = -2; m(sze, jplus) = 1;
    mask{1, j} = m ./ (j*hVert);
    
    m = template;
    m(jplus, 1) = 1; m(jplus, jplus) = -2;  m(jplus, sze) = 1;
    mask{2, j} = m ./ (j*hHorz);
    
    m = template;
    m(1) = 1; m(jplus, jplus) = -2;  m(end) = 1;
    mask{3, j} = m ./ (j*hDiag);
    
    m = template;
    m(1, sze) = 1; m(jplus, jplus) = -2;  m(sze, 1) = 1;
    mask{4, j} = m ./ (j*hDiag);   
end