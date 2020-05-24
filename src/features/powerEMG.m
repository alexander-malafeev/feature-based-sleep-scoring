function [  powEMG ] = powerEMG( EMG, fs,  epochl, windowl )

	df = 1/windowl;
	fl = 15;
	fh = 30;
	ind_pEMG=round(fl/df)+1:round(fh/df)+1; % power in 15-30 Hz range of EMG

	maxep = numel(EMG)/(fs*epochl);
	powEMG=zeros(1,maxep);

	for ep=1:maxep
	    i1 = (ep-1)*epochl*fs+1;
	    i2 = (ep)*epochl*fs; 
	    data = EMG(i1:i2);    
	    PEMG=pwelch( data, hanning(windowl*fs), 0, windowl*fs, fs);
	    powEMG(ep)=sum(PEMG(ind_pEMG));
	end

	powEMG = powEMG';

end