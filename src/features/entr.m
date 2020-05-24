function [  entrop ] = entr( S, fs,  epochl  )

	maxep = numel(S)/(fs*epochl);
	s1 = reshape(S, [fs*epochl maxep] );
	N = floor( sqrt(fs*epochl) );
	p = hist(s1,N);
	pl = p;
	pl( find(p==0) )  = 1;
	entrop = -sum(p/N.*log(pl/N));

end