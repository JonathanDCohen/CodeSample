function err = errorCheck(x0, x, y, div, lambda, h, jmax, mask)
%FUNCTION ERR = ERRORCHECK(X0, X, Y, DIV, LAMBDA, H, JMAX, MASK), Checks 
%the squared A posteriori error bound 
%|x-x^*|^2 <= 2*lambda(F(grad)-<grad,y>) + |x+lambda * div-x^0|^2, obtained
%from the duality gap for the pointwise Besov Denoising problem.
%
%INPUTS:
%   x0: the noisy input image, with padding
%   x: the current iteration of the primal variable
%   y: the current iteration of the dual variable
%   div: the second divergence of y
%   lambda: the Lagrange Multiplier being used
%   h: the geometric mean of the grid size
%   jmax: the current number of scales being considered
%   mask: cell aray of convolution masks for calculating gradients
%
%OUTPUTS:
%   err: an upper bound on the squared L2 error between the optimal
%       solution x^* and the current primal variable x
%Code by Jonathan Cohen, July 2013

MAXSCALES = size(mask, 2);
[M, N] = size(div);

grad = besovGrad(x, M, N, mask, jmax, MAXSCALES);

% - Strip padding - %
x = centerPart(x, 2*MAXSCALES);
x0 = centerPart(x0, 2*MAXSCALES);
y = centerPart(y, MAXSCALES);
grad = centerPart(grad, MAXSCALES);

% - Calculate Error Bound - %
% Estimate dual error %
                         %v--------------|grad|(B^1_inf(L1))----------------v
dual = 2 * lambda * h^2 * (max(sum(sum(sqrt(sum(grad .^ 2, 3)), 1), 2), [], 4) ...
                      - sum(sum(sum(sum(grad .* y, 3)))));
                       %^----------<grad, y>-----------^
                       
% Estimate primal error %
primal = Lp(x + lambda * div - x0, 2)^2;
err = dual + primal;