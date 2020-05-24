%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all; fclose all;



load('model.mat');


dataFolder  =  './data1/'

out = './pred1/'

if ( ~exist([out ], 'dir') ) 
   mkdir(out);
end

f_list = dir( [dataFolder '*.mat'] ); 



y  = []
y_ = []
i_l = 1
for i=1:length(f_list)
    fname = f_list(i).name
    
    [dataFolder fname]
    load( [dataFolder fname] );
    X = X(:,features_ndx);
    
    [label,score] = predict(model,X);
    
    y_ = str2num(cell2mat(label))';
    % you can smooth the result with a median filter
    %y_ = medfilt1( y_, 3);
    save([out  '/' fname], 'y', 'y_','Pspec');

    % =============== Plot  =====================
np = 2;
clim=[-20 30]; % scaling of color coded spectra
% PLOT SPECTRUM
    maxep = numel(y_);
    faxis=0:1/5:fs/2;                  %frequency axis [Hz]
    eaxis=1:maxep;
    taxis=(eaxis-1)*epochl/3600; %time axis 

  FigHandle = figure('Position', [100, 100, 1000, 500]);        



      ax1 = subplot(np, 1, 1);

      plot(taxis,y_);
      axis([taxis(1) taxis(end) 0 4])
       ylabel('Sleep stage');
       ax2 = subplot(np, 1, 2);
       colormap(ax2,'jet');

       imagesc(taxis,faxis,10*log10(Pspec),clim);
       hold on;
       axis xy;
       axis([taxis(1) taxis(end) 0 60])
       ylabel('Frequency [Hz]')
       xlabel('time [h]');

        % without this option spectrogram will disappear
        set(gcf,'render','painters')
        print(gcf, '-dtiff', '-r100', [out  '/' fname '.tiff'])

end

