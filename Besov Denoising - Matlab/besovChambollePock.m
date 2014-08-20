function [out, y] = besovChambollePock(im, lambda, errBound)
%FUNCTION [OUT, Y] = BESOVCHAMBOLLEPOCK(IM, LAMBDA, NOTIFY) denoises the noisy input
%image by minimizing the functional ||out - im|| + lambda *
%|out|(B^1_inf(L1)), as in Buzzerd, Chambolle, Cohen, Levine, and Lucier,
%"Pointwise Besov Space Smoothing of Images", using the Chambolle-Pock
%primal-dual method.
%
%INPUTS:
%   im: noisy image to be cleaned
%   lambda: unnormalized Lagrange multiplier.  This should be appropriate to noise level
%			so that the same multiplier may be used independently of image 
%           size. Default is 12.
%   errBound: squared error tolerance to decide whether or not to stop the outer iterations.  
%			Default is .25.
%
%OUTPUTS:
%   out: cleaned ouput image
%   y: the vector field corresponding to out: out = im - lambda * div(y)
%
%Code written by Jonathan Cohen, Duquesne University, July 2013

% - * - PREPROCESSING - * - %

% - Check Inputs - %
if isinteger(im)
    x = double(im);
    imIsInt = true;
else
    x = im;
    imIsInt = false;
end

if nargin < 3
    errBound = .25;
end
if nargin < 2
    lambda = 12;
end
if (nargin < 1) || (nargin > 3)
    error('Invalid input.')
end

% - Initializations - %
MAXSCALES = 30;                 % Maximum allowed number of scales
jmax = 4;                       % Initial working number of scales
zmin = 4;                       % Minimum maintained number of zero scales

[M, N] = size(x);
hHorz = 1/N;                            %\
hVert = 1/M;                            %-Grid Sizes    
hDiag = sqrt(hHorz^2 + hVert^2);        %/
L = 3*pi/sqrt(hHorz*hVert);             % Operator norm of K

n = ceil(17.2*lambda);          	% A priori estimate on number of iterations
lambda = sqrt(hHorz*hVert) * lambda;    % Normalized Lagrange Multiplier
gamma = 1/lambda;                       % Constant of Uniform Convexity
tau = 1024 / (gamma);                   % Primal Step Size
sigma = 1 / (L^2 * tau);                % Dual Step Size    

x = padarray(x, 2*[MAXSCALES MAXSCALES], 'symmetric');

x0 = x;
xbar = x0;
y = zeros(M + 2*MAXSCALES, N + 2*MAXSCALES, 4, MAXSCALES);

% mask is a cell array containing filter masks used to compute K and K* %
mask = buildMask(MAXSCALES, hVert, hHorz, hDiag); 

inIters = 10;
err = inf;
diff = inf;

nIters = 0;

% - * - MAIN LOOP - * - %
%{ 
n - nIters is the maximum number of iterations left, and diff converges
monotonically to 0, so diff * (n - nIters) is an upper bound on the error
It's unclear when each one of these upper obunds is tighter than the
other, so we just use both.
%}
while (err > errBound) && (diff * (n - nIters) > .5)
    for inner = 1:inIters
    % - Update vector fields - %
        y = y + sigma * besovGrad(xbar, M, N, mask, jmax, MAXSCALES);
        
    % - Project onto the Besov dual-space unit ball - %
        y = dualProx(y, M, N, jmax, MAXSCALES);

    % - Update output image - %
        % Update extrapolation parameter %
        theta = 1/sqrt(1 + 2*gamma*tau);
        
        % save old x in xbar before updating output image %
        xbar = -theta * x;
        
        % Find new guess for output image %
        xOld = x;
        div = besovDiv(y, M, N, mask, jmax, MAXSCALES);
        x = x - tau * padarray(div, 2*[MAXSCALES MAXSCALES], 'symmetric');
        x = primalProx(x, x0, tau, gamma);
        
        % Linearly extrapolate for next iteration %
        xbar = xbar + (1 + theta) * x;
        
        % Update Step Sizes %
        tau = theta * tau;
        sigma = sigma / theta;
        
        % Track convergence in the Cauchy sense %
        diff = Lp(xOld - x, 2);
        nIters = nIters + 1;
    end
    
% - Update working number of scales - %
    scale = jmax;
    numZeroScales = 0;

    while(mu(scale) == 0)
        numZeroScales = numZeroScales + 1;
        scale = scale - 1;
    end   
    jmax = min(jmax + zmin - numZeroScales, MAXSCALES);
    
% - Check Error Bound - %
    err = errorCheck(x0, x, y, div, lambda, .5*(hHorz + hVert), jmax, mask);
    disp(['Error (', num2str(nIters), ' iterations): ', num2str(err)]);
end

% - OUTPUT - %
out = centerPart(x, 2*MAXSCALES);

if imIsInt
    out = uint8(out);
end
y = centerPart(y, MAXSCALES);

end

function yOut = dualProx(y, M, N, jmax, MAXSCALES)
    % Find norms of vectors in y %
    yMags = sqrt(sum(y .^ 2, 3));

    % Sort the magnitudes, find limiters, and calculate projected y %
    muj = reshape(centerPart(yMags, MAXSCALES), M*N, MAXSCALES);
    mu = findMus(muj(:, 1:jmax));
    
    % Shrink the vectors longer than the limiters in length %
    yOut = applyLimiters(y, yMags, mu, jmax);
end

function xOut = primalProx(x, x0, tau, gamma)
    xOut = (x + tau * gamma * x0) ./ (1 + tau * gamma);
end


