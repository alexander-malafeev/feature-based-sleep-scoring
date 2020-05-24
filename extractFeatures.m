function [ X, features_names ] = extractFeatures( Pspec, signal,  EOG,  EMG, epochl, fs, windowl, LOC, ROC)

addpath ./src/features

if ~exist('epochl','var') || isempty(epochl)
    epochl=30;
end
 
if ~exist('fs','var') || isempty(fs)
    fs=200;
end

if ~exist('windowl','var') || isempty(windowl)
    windowl=5;
end
f = (epochl+0.0)/10.0;

df = 1/windowl;






slowWaves  = SlowWaves( signal, fs,  epochl );

[   powEMG ] = powerEMG( EMG, fs,  epochl, windowl );
[   powEOG ] = powerEOG( EOG, fs,  epochl, windowl );
[ Delta, Theta, Alpha, Spindles, Beta,  Gamma ] = extractBands( Pspec, fs,  df );
[ cFreq ] = centralFreq( Pspec, fs,  df );

SEF50 = SEF( Pspec, fs,  df, 0.5, [8 16] );
SEF95 = SEF( Pspec, fs,  df, 0.95, [8 16] );
SEFd = SEF95-SEF50;

% detect REM
[SEM, ~, HFwavelet] = detectSEM(EOG, fs, epochl);
[rem_w, blinks_w, eog_art ] = blinks_wav(LOC, ROC, fs, epochl);

features_names = {'slowWaves', 'EMG', 'EOG/Delta','Spindles', 'Delta',...
    'Theta', 'Alpha',  'Beta', 'Gamma',...
     'Alpha/Theta', 'Beta/Theta','Alpha/Delta', 'Delta/Theta', ...
    '(Delta*Alpha)/(Beta*Gamma)', 'Theta^2/(Delta*Alpha)', 'Central freq.', ...
      'blinks_wav','rem_wav',  'SEM', ...
     'eog_art'};
 
features = [slowWaves, powEMG, powEOG./Delta, Spindles, Delta, Theta, ...
   Alpha, Beta,  Gamma,  Alpha./Theta, Beta./Theta, Alpha./Delta, ...
     Delta./Theta, (Delta.*Alpha)./(Beta.*Gamma), Theta.^2./(Delta.*Alpha),...
     cFreq', blinks_w', rem_w' , SEM', eog_art' ];

X = [ features];

 ndx = [2:16];
    X = log(log(X+1)+1);
   X(:,ndx) = log(X(:,ndx)+1);
 

end
