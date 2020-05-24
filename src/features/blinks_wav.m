function [rem_w, blinks_w, eog_art ] = ...
    blinks_wav(LOC, ROC, fs, epochl)

	% for details see 
	% Malafeev et al. Automatic Human Sleep Stage Scoring Using Deep Neural Networks
	% https://www.frontiersin.org/articles/10.3389/fnins.2018.00781/full
	% (supprting information)

	% % =========== notch filter ========
	% can be omitted since it was already applied  in the conversion function
	% wo = 50/(fs/2);  bw = wo/35;
	% [b,a] = iirnotch(wo,bw);
	% LOC= filter(b,a,LOC);
	% ROC= filter(b,a,ROC);

	% ===== resample=========
	% g =  gcd(128,fs);
	% p = 128/g;
	% q = fs/g;
	% LOC = resample(LOC,p,q);
	% ROC = resample(ROC,p,q);
	% fs = 128;

	% Eye blinks have a characteristic symmetric shape and their duration is
	% short. We performed continuous wavelet transform with 32 levels of the LOC
	% and ROC signals. We chose a Mexican hat wavelet because the shape of this
	% wavelet is close to the shape of an eye blink. 

	ccfsL=cwt(LOC,1:32,'mexh');
	ccfsR=cwt(ROC,1:32,'mexh');

	% Then we sum all the coefficients and get two signals
	wl = sum(ccfsL(:,:));
	wr = sum(ccfsR(:,:));


	%Cor = MovCorr1(sum(ccfsL)',sum(ccfsR)',fs/8);

	% The next step was to find peaks in wl
	% (corresponding to LOC). We selected peaks with minimal height of 4000
	% separated by at least 0.2 s. (Note that function findpeaks was introduced
	% recently in Matlab; we used version 2015b). 

	[wlPK, wlPKpos, widths ] = findpeaks( wl, 'MinPeakHeight',4000, 'MinPeakDistance', round(0.2*fs));


	% Then we selected only the peaks with an amplitude ratio wl/wr smaller
	% than -2. This condition ensures that we reject positively correlated deflections
	% and requires that at least a minor anticorrelated deflection in ROC is present,
	% which is usually the case for eye blinks. A second condition was the following –
	% the ratio of the amplitude to the width of the peak should be > 150 samples
	% (approx. 1 s) as we only need to consider narrow peaks because eye blinks are
	% short lasting events.
	% Following Matlab code implements two conditions mentioned above: 

	ndx1 = wlPKpos(find(wl(wlPKpos)./wr(wlPKpos)<-2.0));
	ndx2 = wlPKpos(find((wl(wlPKpos)./widths)>150));

	blnkpos = intersect(ndx1, ndx2);


	% wlpos = zeros(size(wl));
	% wlpos(find(wl>5000)) = 1;
	% wlratio = zeros(size(wl));
	% wlratio( find(abs(wl)./abs(wr)>3) ) = 1;


	%tmp = -(wl+wr).*(abs(wl)-abs(wr)).*(Cor'-1)/1000000;
	% tmp = wl.*wlpos.*wlratio;
	%  %hold off;
	% %plot(tmp/1000000+300, 'm')
	% tmp(find(isnan(tmp))) = 0;
	% tmp(find(tmp<0)) = 0;
	blinks = zeros(size(LOC));
	%tr = 385;
	blinks(blnkpos) = 1;
	%blinks = tmp;
	blinks = reshape(blinks,[fs*epochl], []);

	blinks_w = sum(blinks);


	% Then we detect rapid eye movements

	% Since there is a
	% step-like change we used a Haar wavelet to capture it.
	% We performed continuous wavelet transform (Haar wavelet) with 32
	% levels of the LOC and ROC signals and summed up of the coefficients. 
	 
	ccL=cwt(LOC,1:32,'haar');
	ccR=cwt(ROC,1:32,'haar');


	% Since there is a
	% step-like change we used a Haar wavelet to capture it.
	% We performed continuous wavelet transform (Haar wavelet) with 32
	% levels of the LOC and ROC signals and summed up of the coefficients. 

	Cor1 = MovCorr1(LOC',ROC',fs/8);
	wl = sum(ccL(:,:));
	wr = sum(ccR(:,:));
	wlwr = wl.*wr/1000000*5.*(Cor1'-1);
	 
	% Then we select the peaks in wlwr
	[wlwrPK, PKpos, widths1 ] = findpeaks( wlwr, 'MinPeakHeight',10, 'MinPeakDistance', round(0.05*fs));

	% We required a minimal height of 10 and minimal distance between
	% peaks of 0.05 s. Saccadic eye movements can occur very quickly one after
	% another. That is the reason we have chosen such a short interval.
	% The next step was to filter out the peaks which correspond to rapid and
	% saccadic eye movements. 

	% We required a ratio of amplitudes between wl and wr of -0.3 and -1.7.
	% Ideally it should be equal to -1 but, it may vary depending on the electrode
	% position and signal quality.
	% Moreover, the ratio of the amplitude of wlwr to the width of the peak
	% should be >1 to make sure that we do not confuse REMs with artifacts and
	% slow eye movements. We also constrained the width of the peak. It had to be
	% wider than 5 samples. This is very short but filters out artifacts (spikes). 


	ndx11 = PKpos(find(wl(PKpos)./wr(PKpos)<-0.3));
	ndx12 = PKpos(find(wl(PKpos)./wr(PKpos)>-1.7));
	ndx1 = intersect(ndx11, ndx12);
	ndx2 = PKpos(find((wlwr(PKpos)./widths1)>1.0));
	ndx3 = PKpos(find(widths1>5));

	ndx23 = intersect(ndx2, ndx3);
	rempos = intersect(ndx1, ndx23);


	rmc = zeros(size(LOC));
	rmc(rempos) = 1;
	rmc = sum(reshape(rmc,[fs*epochl], []));
	rem_w = rmc;


	eog_art_L = zeros(size(LOC));
	eog_art_L(find(abs(LOC)>=350)) = 1;
	eog_art_L = reshape(eog_art_L,[fs*epochl], []);
	eog_art_L = sum(eog_art_L);

	eog_art_R = zeros(size(ROC));
	eog_art_R(find(abs(ROC)>=350)) = 1;
	eog_art_R = reshape(eog_art_R,[fs*epochl], []);
	eog_art_R = sum(eog_art_R);

	eog_art = eog_art_L+eog_art_R;