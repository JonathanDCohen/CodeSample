function [out, mu, index] = limiterF(nu, nuj, muj)
%FUNCTION [OUT, MU, INDEX] = LIMITERF(NU, NUJ, MUJ) calculates the function
%F(nu) = sum(mu) - 1 for which we would like to find a root.
%
%INPUTS:
%   nu: the current best guess at the root of F
%   nuj: matrix of possible nu values
%   muj: matrix of corresponding mu values to the nu values in nuj
%
%OUTPUTS:
%   out: the value of F(nu)
%   mu: the corresponding set of limiters to nu
%   index: the indices in muj where the limiters are found
%Code by Jonathan Cohen, April 2013

jMax = size(nuj, 2);
mu = zeros(1, jMax);
index = zeros(1, jMax);

for j = 1:jMax
    if nu >= nuj(end, j)
        continue
    end
       
    index(j) = binarySearch(nuj(:, j), nu);
    mu(j) = linInterp(nu, nuj(index(j), j), nuj(index(j) + 1, j), ...
                          muj(index(j), j), muj(index(j) + 1, j));
end
out = sum(mu) - 1;
