function yOut = applyLimiters(y, yMags, mu, jmax)
%FUNCTION YOUT = APPLYLIMITERS(Y, YMAGS, MU, JMAX) projects a sequence of
%vector fields, y, to a ball in the space dual to B^1_inf(L1) according to
%limiters mu.
%
%INPUTS:
%   y: the sequence of vector fields to project
%   yMags: the norms of each vector in y
%   mu: array of limiters for each scale in y
%   jmax: the number of scales currently being considered
%
%OUTPUTS:
%   yOut: the projection of y onto some ball.
%
%Code by Jonathan Cohen, Duquesne University

yOut = zeros(size(y));
for scale = 1:jmax
    mults = min(1, mu(scale) ./ yMags(:, :, scale));
    for dim = 1:4
        yOut(:, :, dim, scale) = y(:, :, dim, scale) .* mults;
    end
end