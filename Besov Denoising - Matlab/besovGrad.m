function y = besovGrad(x, M, N, mask, jmax, MAXSCALES)
%FUNCTION y = BESOVGRAD(X, M, N, MASK, JMAX, MAXSCALES) computes the
%"second gradient" of an image, x.
%
%INPUTS:
%   x: image for which to calculate the gradient
%   M, N: the original image size, which is also the output size
%   mask: convolution masks to use in the calculation
%   jmax: the number of scales to consider
%   MAXSCALES: the total number of scales in the output
%
%OUTPUTS:
%   y: the second gradient of x
%Code by Jonathan Cohen, Duquesne University

y = zeros(M + 2*MAXSCALES, N + 2*MAXSCALES, 4, MAXSCALES);
for scale = 1:jmax
    for dim = 1:4
        z = conv2(x, mask{dim, scale}, 'valid');
        y(:, :, dim, scale) = centerPart(z, MAXSCALES, scale);
    end
end