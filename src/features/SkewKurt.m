function [  skew, kurt ] = SkewKurt( S, fs,  epochl  )
	maxep = numel(S)/(fs*epochl);
	s1 = reshape(S, [fs*epochl maxep] );

	skew = skewness(s1);
	kurt = kurtosis(s1);
end