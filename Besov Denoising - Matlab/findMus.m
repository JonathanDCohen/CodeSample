function mu = findMus(muj)
%FUNCTION MU = FINDMUS(MUJ) finds limiters for projecting onto the unit ball 
%in the dual space to B^1_inf(L1).  See Section 5 in Buzzard, Chambolle, Cohen,
%Levine, and Lucier "POINTWISE BESOV SPACE SMOOTHING OF IMAGES"
%
%INPUTS:
%   muj: matrix where the jth column is the sorted vector magnitudes in the
%       jth vector field in the current iteration of the dual variable, y.
%
%OUTPUTS:
%   mu: the array of correct limiters needed to project y to the unit ball
%   in the dual space to B^1_inf(L1)
%Code by Jonathan Cohen: Duquesne University, April 2013

%Check if vector fields are already in the unit ball
muj = sort(muj, 'descend');
mu = muj(1, :);
if sum(mu) <= 1
    return
end

% --- *** --- PREPROCESSING --- *** --- %
[Nsqd, jMax] = size(muj);
err = 1e-6;

% Calculate Discrete Nu's %

muj = [muj; zeros(1, jMax)];
l = repmat((0:Nsqd)', 1, jMax); %(a:b) is a row vector
cSum = [zeros(1, jMax); cumsum(muj(1:(end-1), :))];
nuj = cSum - l .* muj;

% Initialize bracketing values for Ridders' Method %
nu1 = 0;           
nu2  = max(nuj(:)); 
fNu1 = sum(mu) - 1; 
fNu2 = -1;
fNu4 = inf;

% --- *** --- MAIN LOOP --- *** --- %
while abs(fNu4) > err
    % Update nu using Ridders' Method %
    nu3 = .5*(nu1 + nu2);
    fNu3 = limiterF(nu3, nuj, muj);

    nu4 = nu3 + (nu3 - nu1) * fNu3 / sqrt(fNu3^2 - fNu1*fNu2);
    [fNu4, mu] = limiterF(nu4, nuj, muj);

    % Re-bracket the true nu %
    if fNu4 > 0
        nu1 = nu4;
        fNu1 = fNu4;
        if fNu3 < 0
            nu2 = nu3;
            fNu2 = fNu3;
        end
    elseif fNu4 < 0
        nu2 = nu4;
        fNu2 = fNu4;
        if fNu3 > 0
            nu1 = nu3;
            fNu1 = fNu3;
        end
    end
end



