%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all; fclose all;

addpath ./src/features/
global epochl;
rng(0)


NumTrees = 70;

dataFolder  = './data/'

load('file_sets.mat')

load([ dataFolder  files_train{1}] );
features_ndx =  [1:size(X,2)];

model_name = 'model';

[ X_train, y_train,X_cv, y_cv, X_test, y_test, seq ] = prepareTrainingData( dataFolder, files_train, files_CV,files_test, features_ndx );


fprintf('\nTraining the model ...\n')

model = TreeBagger(NumTrees,X_train,y_train, 'OOBVarImp', 'on', 'Prior', 'Uniform');

labels_train_str = cell2mat(predict(model,X_train));

[labels_train] = str2num(labels_train_str);
stats_train = confusionmatStats(y_train',labels_train);
[ accuracy_train] = findErrors(y_train', labels_train);
fprintf(['============================\n'])
fprintf(['Accuracy on the  train set: \n'])
fprintf( [num2str(1-accuracy_train) '\n']);
fprintf(['F1 score on the train set: \n'])
fprintf(['W\t\tS1\t\tS2\t\tS3\t\tR\n'])
for i=1:5 a{i} = num2str(stats_train.Fscore(i), 3);end;
    fprintf([a{1} '\t' a{2} '\t' a{3} '\t' a{4} '\t' a{5} '\n']);



    labels_cv_str = cell2mat(predict(model,X_cv));
    size(labels_cv_str);
    [labels_cv] = str2num(labels_cv_str);
    stats_cv = confusionmatStats(y_cv',labels_cv);
    [ accuracy_cv] = findErrors(y_cv', labels_cv);
    fprintf(['============================\n'])
    fprintf(['Accuracy on the  CV set: \n'])
    fprintf( [num2str(1-accuracy_cv) '\n']);
    fprintf(['F1 score on the CV set: \n'])
    fprintf(['W\t\tS1\t\tS2\t\tS3\t\tR\n'])
    for i=1:5 a{i} = num2str(stats_cv.Fscore(i), 3);end;
        fprintf([a{1} '\t' a{2} '\t' a{3} '\t' a{4} '\t' a{5} '\n']);

        save( [ model_name '.mat'], 'model', 'features_ndx' );

        load([dataFolder files_CV{1}]);
        X = X(:,features_ndx);

        [label,score] = predict(model,X);


        y = str2num(cell2mat(label));


  
% =============== Plot  =====================
np = 3;
clim=[-20 30]; % scaling of color coded spectra
% PLOT SPECTRUM
    faxis=0:1/5:fs/2;                  %frequency axis [Hz]
    eaxis=1:maxep;
    taxis=(eaxis-1)*epochl/3600; %time axis [h]
  % taxis=SleepEEG_Spectra.PlotParameters.TimeAxisInH;


  FigHandle = figure('Position', [100, 100, 1000, 500]);        


      ax1 = subplot(np, 1, 1);

      plot(eaxis,stages );
      set(gca, 'XTickLabel', []);
      ylabel('Sleep stage');


      ax2 = subplot(np, 1, 2);

      plot(eaxis,y);
       ylabel('Sleep stage');
       ax3 = subplot(np, 1, 3);
       colormap(ax2,'jet');

       imagesc(taxis,faxis,10*log10(Pspec),clim);
       hold on;
       axis xy;
       axis([taxis(1) taxis(end) 0 60])
       ylabel('Frequency [Hz]')
       xlabel('time [h]');

        % without this option spectrogram will disappear
        set(gcf,'render','painters')
        print(gcf, '-dtiff', '-r100', 'figure1.tiff')
        hgexport(FigHandle,['figure1.fig']);

        save('tmp.mat', 'score', 'label', 'stages');


