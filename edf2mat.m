clear; clc; close all; fclose all;

% this script reads edf files, performs feature extraction and 
% saves a structure with features to matlab format

addpath ./src/features/
addpath ./src/tools/

% folder with your data 
readPath = '../EDF/'

% folder with the  files containing scoring  
% if you are not training your own model you don't need it
% (leave variable undefined to omit reading scoring data)
%scoringFolder = './scoring/'

% folder where we will save converted files
writePath = './data1/'
% folder to save images
imgPath = './spectra/'

C3_lbl = 'C3';
A2_lbl = 'A2';

C3A2_lbl = 'C3_A2';
C4A1_lbl = 'C4_A1';
LOC_lbl = 'LOC';
ROC_lbl = 'ROC';
EMG_lbl = 'CHIN';

% label of the channel in the scoring file. Labels format can be 
% different in scoring and data files.
% you only need it if you are training your own model
channelName = 'C3A2';
global epochl;


% frequency of powerline; 60 Hz in USA
f_powerline = 50;

% it is the epoch length for the spectrogram calculation
% most of the time it is 30 seconds
epochl=20; % seconds

% window length used for spectrogram calculation
% we split every epoch into windows, in this case 20 second epoch is split
% into 4 windows, each 5 seconds long
% then spectra is computed for every window and avaraged
windowl=5; % seconds

% resolution of a spectrogram in frequency axis
df=1/windowl;
% default sampling rate
fs = 256;

% indexes of spectrogram columns to compute power in certain ranges
ind_pEMG=15/df+1:30/df+1; % 15-30 Hz range of EMG

%%ind_pEOG=1/df+1:5/df+1; % power in 1-5 Hz range of EOG


% set it to 0 if you don't want plots
plotspectra = 1;

if ( ~exist([writePath ], 'dir') ) 
   mkdir(writePath);
end

if ( ~exist([imgPath ], 'dir') ) 
   mkdir(imgPath);
end


fileList = dir( [ readPath '*.edf' ] )



for f = 1:length(fileList)
    
    recording  = fileList(f).name
    recording = recording(1:end-4);
    
    fileName = [recording '.edf'];
    [HDR, signalHeader, signalCell] = blockEdfLoad([readPath, fileName], { C3A2_lbl, C4A1_lbl,LOC_lbl, ROC_lbl, EMG_lbl });
   
    % convert a cell array of structures into the cell array containing 
    % only the field signal_labels
    labels = {signalHeader.signal_labels};
    % convert cell array of vectors into matrix  where vectors  are columns
    data_rec = [signalCell{:}];

    % here we are finding which rows of data matrix correspond to 
    % the channels of interest
    %chF3A2=ismember(HDR.Label,'F3-A2','rows');
    chC3A2=strcmp(labels,C3A2_lbl);
    %chO1A2=ismember(HDR.Label,'O1-A2','rows');
    %chF4A1=ismember(HDR.Label,'F4-A1','rows');
    chC4A1=strcmp(labels,C4A1_lbl);
    %chO2A1=ismember(HDR.Label,'O2-A1','rows');
    
    chC3=strcmp(labels,C3_lbl);
    chA2=strcmp(labels,A2_lbl);
    
    chEMG=strcmp(labels,EMG_lbl);
    %chEMG1=ismember(HDR.Label,'CHIN1-CHIN2','rows');
    %chEMG2=ismember(HDR.Label,'CHIN2-CHIN3','rows');
    chEOG1=strcmp(labels,LOC_lbl);
    chEOG2=strcmp(labels,ROC_lbl);
    
    % maximal index of used channels 
    % we need it to trim the data matrix
    %nChan = max([find(chC3A2==1), find(chC4A1==1), find(chEOG1==1), find(chEOG2==1), find(chEMG==1) ]);


    % some data from the header
    %fs=HDR.SampleRate; %sample rate
    %fse=HDR.SampleRate; %sample rate EOG
    %fsm=HDR.SampleRate; %sample rate EMG
    fs = round(1/HDR.data_record_duration);
    fse = fs;
    fsm = fs;
    % how many 20 second epochs are in our file
    maxep=floor(HDR.num_data_records/(epochl/HDR.data_record_duration)); 
 
    % arrays for the spectrogramms 
    % we will use only PC3A2, but you can uncomment and use others as well
    
    %PF3A2=zeros(fs/2/df+1,maxep);
    PC3A2=zeros(fs/2/df+1,maxep);
    %PO1A2=zeros(fs/2/df+1,maxep);
    %PF4A1=zeros(fs/2/df+1,maxep);
    PC4A1=zeros(fs/2/df+1,maxep);
    %PO2A1=zeros(fs/2/df+1,maxep);
    
    % array for power of EMG
    powEMG=zeros(1,maxep); % EMG power in the band 15-30 Hz
    


 
    % notch filter to remove powerline noise    
    % apply filter for every channel
    for i = 1:size(data_rec,2)
        data_rec(:,i)= bandstop(data_rec(:,i),[49 51],fs);
    end

 

   % truncate signals, i.e. it should contain integer number of epochs
    data_rec = data_rec(1:maxep*epochl*fs,:);
    % structure Data is what we are going to save
    Data.windowl = windowl;

    




    % this array contains stages of sleep
    % we set it to zeros if scoring is not provided
    % if you want to train networks on your own data you have to set this array
    % 0 is Wake, 1, 2, 3 - stages 1-3 and 4 is for REM sleep
    stages = zeros(1,maxep);
    
    % function readScoringFile is specific to the file format we had 
    % for the training data. You should substitute it with your own
    % function in case you want to convert the data for training
    % if you just want to score your data leave this line commented out
    if exist('scoringFolder','var')% || ~isempty(scoringFolder)

        scoring_file = [scoringFolder, recording, '.mat'];
        stages = readScoringFile(scoring_file, channelName);

        % in our case the scoring was only till the subjects were woken up\
        % thus we fill the rest of the stages with zeros (Wake)
        stages = [stages repmat('0',1,maxep-numel(stages))];
        %Data.stages = stages;
        % function stagesSym2NRW is  needed to convert symbolic representation
        % of sleep stages to numeric. We also don't provide it
        stages = stagesSym2NRW(stages);
    end
    % save the channel's labels
    %Data.channel_names = HDR.label;


    % we resample the data to 128 Hz; your data should have sampling rate
    % higher than 128 Hz

    
    %A2 = resample(A2,p,q);
    % C3A2 = resample(C3A2,p,q);
    % C4A1 = resample(C4A1,p,q);
    % F3A2 = resample(C3A2,p,q);
    % F4A1 = resample(C4A1,p,q);
    % O1A2 = resample(O1A2,p,q);
    % O2A1 = resample(O2A1,p,q);

    % EMG and ocular channels
    
    C3A2 = zeros(1, maxep*epochl*fs);
    EMG = zeros(1, maxep*epochl*fs);
    LOC = zeros(1, maxep*epochl*fs);
    ROC = zeros(1, maxep*epochl*fs);
    
       C3A2 = data_rec(:,chC3A2);
     LOC = data_rec(:,chEOG1);
     ROC = data_rec(:,chEOG2);
     if sum(chEMG)>0
         EMG = data_rec(:,chEMG);
     end

     
    g =  gcd(128,fs);
	p = 128/g;
	q = fs/g;
	fs = 128;
    
     C3A2 = resample(data_rec(:,chC3A2),p,q);
     LOC = resample(data_rec(:,chEOG1),p,q);
     ROC = resample(data_rec(:,chEOG2),p,q);
     if sum(chEMG)>0
         EMG = resample(data_rec(:,chEMG),p,q);
     end

    
    EOG = LOC-ROC;
    
    
    
    
[ FFT ] = amf_spectrogram(C3A2, fs, epochl, windowl);
 
    
  
 Pspec = FFT;
 signal = C3A2;
 %signal = C3A2(1:maxep*epochl*fs)';
 %EOG = EOG(1:maxep*epochl*fs)';
 %EMG = EMG(1:maxep*epochl*fs)';
 %LOC = LOC(1:maxep*epochl*fs)';
 %ROC = ROC(1:maxep*epochl*fs)';
 
 clear data_rec;
 
[ X, features_names ] = ...
            extractFeatures( Pspec, signal,  EOG,  EMG,...
            epochl, fs, windowl, LOC, ROC);

    
    
    %  PLOT SPECTRUM
    faxis=0:1/5:fs/2;                  %frequency axis [Hz]
    eaxis=1:maxep;
    taxis=(eaxis-1)*epochl/3600; %time axis [h]
    clim = [-20 30];
    if plotspectra
        FigHandle = figure;
        subplot(211)
        plot( eaxis, stages );
        subplot(212)
        imagesc(taxis,faxis,10*log10(FFT),clim);
        axis xy;
        axis([taxis(1) taxis(end) 0 45])
        ylabel('frequency [Hz]')

    end
      

 print(gcf, '-dtiff', '-painters', [imgPath '/' recording  '.tiff']);
    
 
    Data.Label = labels;
    
    Data.epochl = epochl;
     Data.fs = fs;
    Data.df = df;
     Data.signal=C3A2;
    Data.Pspec = FFT;
     Data.maxep = maxep;
    Data.Stages = stages;
 
      save([writePath recording '.mat'], 'Pspec', 'stages', 'channelName', 'X', 'features_names', ...
  'fs', 'epochl', 'windowl', 'df', 'maxep'); 
       
end