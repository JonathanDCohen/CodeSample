function y = linInterp(x, x0, x1, y0, y1)
%FUNCTION Y = LININTERP(X, X0, X1, Y0, Y1) calculates a liner interpolation
%with no bounds checking to avoid the repeated overhead. 
%
%INPUTS:
%   x: the location where we are interested in an interpolated value
%   x0: the left endpoint of the interval to interpolate over
%   x1: the right endpoint of the interval to interpolate over
%   y0: some function value at x0
%   y1: some function value at x1
%
%OUTPUTS:
%   y: the interpolated value
%Code by Jonathan Cohen, April 2013

y = y0 + (y1 - y0) * (x - x0) / (x1 - x0);