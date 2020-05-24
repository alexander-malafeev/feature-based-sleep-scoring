function [ count ] = SlowWaves( signal, fs,  epochl )

% this function computes slow waves. In the original version for the paper
% we used an implementation of slow waves detection algorithm by Alessia Bersagliere
% This is the simplified version implemented by Alexander Malafeev
% we compared the results and they look very similar. Thus I don't expect that
% the simplification of the algorithm would affect classification

FiltData = bandpass( signal, [0.5 2], fs );


Threshold = 37.5;

[pks,locs] = findpeaks(FiltData,'MinPeakHeight', Threshold, 'MinPeakWidth', 0.5/4);


count = zeros(size(signal));
count(locs) = 1;
count = reshape(count, [fs*epochl], [] );
count = sum(count)';

end