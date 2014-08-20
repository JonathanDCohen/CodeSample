function div = besovDiv(y, M, N, mask, jmax, MAXSCALES)
%FUNCTION DIV = BESOVDIV(Y, M, N, MASK, JMAX, MAXSCALES) computes the
%"second divergence" of a sequence of vector fields, y.
%
%INPUTS:
%   y: sequence of vector fields to calculate on
%   M, N: the original image size, which is also the output size
%   mask: convolution masks to use in the calculation
%   jmax: the number of scales to consider
%   MAXSCALES: the total number of scales in y
%
%OUTPUTS:
%   div: the second divergence of y
%Code by Jonathan Cohen, Duquesne University

div = zeros(M, N);
for scale = 1:jmax
    for dim = 1:4
        z = conv2(y(:, :, dim, scale), mask{dim, scale}, 'valid');
        div = div + centerPart(z, MAXSCALES, scale);
    end
end