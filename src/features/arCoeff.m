function [ a, e, rc ] = arCoeff( signal, fs,  epochl, p )
	% p - order of an AR model
	if ~exist('epochl','var') || isempty(epochl)
		epochl=30;
	end

	if ~exist('p','var') || isempty(p)
		p=5;
	end



	maxep = numel(signal)/(fs*epochl);
	a=zeros(maxep,p+1);
	e = zeros(maxep,1);
	rc = zeros(maxep,p);


	for ep=1:maxep
		i1 = (ep-1)*epochl*fs+1;
		i2 = (ep)*epochl*fs;
		
		data = signal(i1:i2);
		
		[ a1, e1, rc1 ] = arburg(data,p);
		a(ep,:) = a1;
		e(ep) = e1;
		rc(ep,:) = rc1';
	end

end