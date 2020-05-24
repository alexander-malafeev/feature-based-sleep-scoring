function [ X_train, y_train,X_cv, y_cv, X_test, y_test, seq1] = prepareTrainingData(  dataFolder, files_train, files_CV, files_test, features_ndx )


% prepare training set
fprintf('\nPreparing training set ...\n')

X_train = [];

trainSet = files_train;
cvSet = files_CV;
testSet = files_test;

stages_tmp = [];
seq1 = {};
for f = 1:length(trainSet)
    [dataFolder '/' trainSet{f}];
    load( [dataFolder '/' trainSet{f} ] );
    idx = 1:maxep;
  
    X_train = [X_train; X(idx,:) ];
    %stages( artifacts ) = 'A';
   
    stages_tmp  = [ stages_tmp, stages(idx) ];
    %seq1{f} = stagesSym2NRW(stages(idx));
end

y_train =  stages_tmp ;

%IDX = randperm( numel(y_train) );

%y_train = y_train( IDX );
%X_train = X_train( IDX, : );


% X_train_p1 = zeros(size(X_train) );
% X_train_p1(2:end, :) = X_train(1:end-1, :);
% X_train_p1(1,:) = X_train(1,:);
% 
% X_train_p2 = zeros(size(X_train_p1) );
% X_train_p2(2:end, :) = X_train_p1(1:end-1, :);
% X_train_p2(1,:) = X_train_p1(1,:);
% 
% X_train = [X_train, X_train_p1, X_train_p2];

% prepare CV set
fprintf('\nPreparing CV set ...\n')
X_cv = [];
stages_tmp = [];
for f = 1:length(cvSet)
    load( [dataFolder '/' cvSet{f} ] );
    idx = 1:maxep;
    %idx = setdiff(idx,artifacts);
    X_cv = [X_cv; X(idx,features_ndx) ];
    % stages( find(artifacts==1)) = 'O';
    stages_tmp  = [ stages_tmp, stages(idx) ];
end

y_cv =  stages_tmp ;


%IDX = randperm( numel(y_cv) );

%y_cv = y_cv( IDX );
%X_cv = X_cv( IDX, : );

% prepare test set
fprintf('\nPreparing test set ...\n')
X_test = [];
stages_tmp = [];
for f = 1:length(testSet)
    load( [dataFolder '/' testSet{f} ] );
    idx = 1:maxep;
    %idx = setdiff(idx,artifacts);
    X_test = [X_test; X(idx,features_ndx) ];
    % stages( find(artifacts==1)) = 'O';
    stages_tmp  = [ stages_tmp, stages(idx) ];
end

y_test =  stages_tmp;











