function [ cFreq ] = centralFreq( Pspec, fs,  df )

	% We computed the “brain rate” [Hz] (Pop-Jordanova and Pop-Jordanov,
	% 2005) as weighted sum of frequency values with weights equal to the relative
	% power density in the corresponding frequency bin. It was computed in the
	% frequency range: 0 - fs/2 Hz; fs sampling rate. Brain rate was reported to be a
	% good measure of mental arousal (Pop-Jordanova and Pop-Jordanov, 2005).
	% Brain rate can be computed using the BioSig package (Schlögl and Brunner,
	% 2008). 


	% for details see 
	% Malafeev et al. Automatic Human Sleep Stage Scoring Using Deep Neural Networks
	% https://www.frontiersin.org/articles/10.3389/fnins.2018.00781/full

	n = size(Pspec,1);
	faxis = 0:df:fs/2;

	cFreq  = (faxis*Pspec)./(sum(Pspec));
end