%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all; fclose all;

data_dir = './data/'
global epochl;
load('predictions_RF_300.mat');

epochl = 20;
fs = 128;

j=1;
for i=1:numel(test_l)
  fname = strtrim( files_test{i} );
  load(strcat(data_dir,fname))
  maxep = test_l(i);
  stages = t_y(j:j+maxep-1);
  stages_ = t_y_(j:j+maxep-1);



  Pspec = Pspec(:,1:maxep);

  j = j+test_l(i);

% =============== Plot Spectra =====================
clim=[-20 30]; % scaling of color coded spectra
% PLOT SPECTRUM
  faxis=0:1/5:fs/2;                  %frequency axis [Hz]
  eaxis=1:maxep;
  taxis=(eaxis-1)*epochl/3600; %time axis [h]

FigHandle = figure('Position', [100, 100, 1049, 895]);        
  ax1 = subplot(3, 1, 1);
  plot( eaxis, stages );
  set(gca, 'XTickLabel', []);
  ylabel('Sleep stage');
  title( files_test(i,:),'Interpreter','none' )

  ax2 = subplot(3, 1, 2);
  plot( eaxis, stages_ );
  ylabel('Sleep stage');

  ax3 = subplot(3, 1, 3);
  imagesc(eaxis,faxis,10*log10(Pspec),clim);
  axis xy;
  % axis([eaxis(1) eaxis(end) 0 40]);
  xlim([eaxis(1) eaxis(end) ]);
  axis([eaxis(1) eaxis(end) 0 60])
  ylabel('Frequency [Hz]')
  xlabel('time [h]');
  % without this option spectrogram will disappear
   set(gcf,'render','painters')

print(gcf, '-dtiff', '-r100', ['./plot/' fname '.tiff'])
end
