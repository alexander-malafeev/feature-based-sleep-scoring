function [ powEOG ] = powerEOG( EOG, fs,  epochl, windowl )

	df = 1/windowl;
	fl = 1;
	fh = 5;
	ind_pEOG=round(fl/df)+1:round(fh/df)+1; % power in 1-5 Hz range of EOG

	maxep = numel(EOG)/(fs*epochl);
	powEOG=zeros(1,maxep);
	EOGsgram = zeros(fs/(2*df)+1,maxep);
	for ep=1:maxep
	    i1 = (ep-1)*epochl*fs+1;
	    i2 = (ep)*epochl*fs;
	    
	    data = EOG(i1:i2);
	    
	    PEOG=pwelch(data,hanning(windowl*fs),0,windowl*fs,fs);
	    EOGsgram(:,ep) = PEOG;
	    powEOG(ep)=sum(PEOG(ind_pEOG));
	end
	powEOG = powEOG';
end